package nft

import (
	"chain"
	"chain/runtime"
	"crypto/merkle"
	"crypto/sha256"
	"encoding/hex"
	"strconv"
	"strings"
	"time"

	"gno.land/p/jeronimoalbi/bloom/v0"
	"gno.land/p/jeronimoalbi/settlers/nft/v0"
	"gno.land/p/nt/bptree/v0"
	"gno.land/p/nt/mdalert/v0"
	"gno.land/p/nt/ownable/v0"
)

const (
	// Name is the NFT token's name.
	Name = "Settlers"

	// Symbol is the NFT token's symbol.
	Symbol = "SETTLER"

	// Capacity is the total number of Settlers that can be minted.
	capacity = 3000

	// Max nonce is how many gnomes are tried for a token before giving up,
	// when the ones that come out are already taken.
	maxNonce = 64

	// Max aunts is the longest proof accepted.
	maxAunts = 40
)

var (
	// Realm path is the path of this realm.
	RealmPath string

	// Notice is a realm-wide message the admin can post at any time, shown at the top of the page.
	// It never affects SVG, URI or Markdown, it is purely informational.
	Notice string

	// NoticeType is the style Notice is shown as.
	NoticeType mdalert.Type

	// Admin account for the realm.
	// This account is only valid to set snapshot params, once setted minting
	// can start and after the first NFT is minted the account is not allowed to change
	// snapshot params anymore.
	// It is always allowed to post or clear realm-wide notices.
	admin *ownable.Ownable

	// Supply cap is the number of Settlers that can be minted.
	supplyCap = capacity

	// Root is the Merkle root value.
	root []byte

	// Total is the total number of leaves of the list of elegible accounts.
	total int

	// Tokens has every token, by ID (zero-padded, so it is in mint order).
	tokens = bptree.NewBPTree32()

	// Claimed has the ID of the token for each account.
	claimed = bptree.NewBPTree32()

	// Seen traits has the packed traits of minted tokens to check that two Settlers are never the same.
	seenTraits = newTraitsFilter()
)

// Token represents a Settler.
type token struct {
	owner  address
	traits uint32
}

func init(cur realm) {
	RealmPath = strings.TrimPrefix(cur.PkgPath(), runtime.ChainDomain())
	admin = ownable.NewWithAddress(cur.Previous().Address())

	// Announce the new collection
	chain.Emit(
		"NewToken",
		"token", CollectionID(),
		"name", Name,
		"symbol", Symbol,
	)
}

// SetSnapshot opens the mint.
// It sets the Merkle root of the list of eligible accounts, in hex, and the
// number of accounts in the list. Only the owner can call it.
// It can be called again to correct a mistake until the first Settler is minted,
// from then on the list is frozen.
func SetSnapshot(cur realm, rootHex string, count int) {
	assertIsCurrent(cur)
	admin.AssertOwnedBy(cur.Previous().Address())

	if tokens.Size() > 0 {
		panic("the snapshot is frozen: Settlers were already minted")
	}

	bz, err := hex.DecodeString(rootHex)
	if err != nil || len(bz) != 32 {
		panic("the root must be 32 bytes in hex")
	}

	if count < 1 {
		panic("the list must have at least one account")
	}

	root = bz
	total = count
	chain.Emit(
		"SnapshotSet",
		"root", rootHex,
		"total", strconv.Itoa(count),
	)
}

// Admin returns the address of the admin account.
func Admin() address { return admin.Owner() }

// TransferAdmin makes another account the admin. Only the admin can call it.
func TransferAdmin(cur realm, newAdmin address) {
	assertIsCurrent(cur)
	if err := admin.TransferOwnership(0, cur, newAdmin); err != nil {
		panic(err)
	}
}

// SetNotice posts a realm-wide message, shown at the top of the page.
func SetNotice(cur realm, alertType mdalert.Type, msg string) {
	assertIsCurrent(cur)
	admin.AssertOwnedBy(cur.Previous().Address())
	assertIsValidAlertType(alertType)

	NoticeType = alertType
	Notice = msg
	chain.Emit("NoticeSet", "type", string(alertType))
}

// ClearNotice removes the current notice.
func ClearNotice(cur realm) {
	assertIsCurrent(cur)
	admin.AssertOwnedBy(cur.Previous().Address())

	NoticeType = ""
	Notice = ""
	chain.Emit("NoticeCleared")
}

// Mint mints a Settler to the caller and returns its id.
//
// The proof shows that the caller is in the list of eligible accounts.
// Proof format is "<index>.<aunts>".
// Only user accounts can mint, either with a call or a run transaction, realms can't.
func Mint(cur realm, proof string) int {
	assertIsCurrent(cur)
	if !cur.Previous().IsUser() {
		panic("only user accounts can mint")
	}

	if len(root) == 0 {
		panic("the mint is not open yet")
	}

	minted := tokens.Size()
	if minted >= supplyCap {
		panic("sold out")
	}

	caller := cur.Previous().Address()
	if claimed.Has(caller.String()) {
		panic("this account has already minted")
	}

	index, aunts, err := splitProof(proof)
	if err != "" {
		panic(err)
	}

	if !merkle.VerifySimpleProof(root, []byte(caller), index, total, aunts) {
		panic("the proof is not valid for this account: " + caller.String())
	}

	settlerID := minted + 1
	prefix := seedPrefix(caller, settlerID)

	var (
		packed    uint32
		packedKey string
	)
	for nonce := 0; ; nonce++ {
		if nonce == maxNonce {
			panic("could not find a new gnome, try again")
		}

		seed := hashSeed(prefix, nonce)
		traits := nft.NewTraits(seed)
		packed = nft.Pack(traits.Normalized())
		packedKey = strconv.FormatUint(uint64(packed), 10)
		if !seenTraits.ContainsString(packedKey) {
			break
		}
	}

	tokens.Set(makeKey(settlerID), token{owner: caller, traits: packed})
	seenTraits.AddString(packedKey)
	claimed.Set(caller.String(), settlerID)
	chain.Emit(
		"Transfer",
		"token", CollectionID(),
		"from", "",
		"to", caller.String(),
		"tokenId", strconv.Itoa(settlerID),
	)
	return settlerID
}

// Cap returns the number of Settlers that can be minted.
func Cap() int { return supplyCap }

// TotalSupply returns the number of Settlers minted so far.
func TotalSupply() int { return tokens.Size() }

// MerkleRoot returns the Merkle root of the list of eligible accounts, in hex.
func MerkleRoot() string { return hex.EncodeToString(root) }

// Total returns the number of eligible accounts in the list.
func Total() int { return total }

// CollectionID returns the ID that the events use for this collection.
func CollectionID() string {
	return runtime.ChainDomain() + RealmPath + "." + Symbol + ".0000000"
}

// OwnerOf returns the owner account of a Settler.
func OwnerOf(settlerID int) address { return tokenOf(settlerID).owner }

// BalanceOf returns the number of Settlers of an account (0 or 1).
func BalanceOf(addr address) int {
	if claimed.Has(addr.String()) {
		return 1
	}
	return 0
}

// TokenOf returns the ID of the Settler of an account, or 0 if it has none.
func TokenOf(addr address) int {
	v := claimed.Get(addr.String())
	if v == nil {
		return 0
	}
	return v.(int)
}

// TraitsOf returns the traits of a Settler.
func TraitsOf(settlerID int) nft.Traits { return nft.Unpack(tokenOf(settlerID).traits) }

func tokenOf(settlerID int) token {
	v := tokens.Get(makeKey(settlerID))
	if v == nil {
		panic("token not found")
	}
	return v.(token)
}

func newTraitsFilter() *bloom.Bloom {
	m := uint64(28756) // bits
	k := uint64(7)     // hashes
	return bloom.NewWithMK(m, k)
}

func generateSeed(caller address, settlerID, nonce int) string {
	return hashSeed(seedPrefix(caller, settlerID), nonce)
}

func seedPrefix(caller address, settlerID int) string {
	return strconv.FormatInt(time.Now().UnixNano(), 10) + ":" + caller.String() +
		":" + strconv.Itoa(settlerID) + ":"
}

func hashSeed(prefix string, nonce int) string {
	sum := sha256.Sum256([]byte(prefix + strconv.Itoa(nonce)))
	return hex.EncodeToString(sum[:])
}

func splitProof(proof string) (int, []byte, string) {
	dot := strings.Index(proof, ".")
	if dot < 1 {
		return 0, nil, "the proof must be <index>.<aunts>"
	}

	index, err := strconv.Atoi(proof[:dot])
	if err != nil || index < 0 || index >= total {
		return 0, nil, "the index of the proof is not valid"
	}

	aunts, err := hex.DecodeString(proof[dot+1:])
	if err != nil || len(aunts)%32 != 0 || len(aunts) > 32*maxAunts {
		return 0, nil, "the aunts of the proof must be hashes of 32 bytes in hex"
	}
	return index, aunts, ""
}

func makeKey(settlerID int) string {
	s := strconv.Itoa(settlerID)
	return strings.Repeat("0", 5-len(s)) + s
}

func assertIsCurrent(cur realm) {
	if !cur.IsCurrent() {
		panic("unauthorized")
	}
}

func assertIsValidAlertType(t mdalert.Type) {
	switch t {
	case mdalert.TypeCaution, mdalert.TypeInfo, mdalert.TypeNote,
		mdalert.TypeSuccess, mdalert.TypeTip, mdalert.TypeWarning:
		return
	}
	panic("invalid notice type")
}
