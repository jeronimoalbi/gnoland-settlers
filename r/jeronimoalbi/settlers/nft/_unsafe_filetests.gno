package nft

import (
	"chain/runtime"
	"strconv"

	"gno.land/p/nt/bptree/v0"
	"gno.land/p/nt/ownable/v0"
)

// UnsafeReset clears the collection back to its just-deployed state and makes owner the admin.
func UnsafeReset(cur realm, owner address) {
	assertIsDevChain()

	root = nil
	total = 0
	collection, ledger = newCollection(cur)
	tokens = bptree.NewBPTree32()
	claimed = bptree.NewBPTree32()
	seenTraits = newTraitsFilter()
	supplyCap = capacity
	admin = ownable.NewWithAddress(owner)
}

// UnsafeSetCap lowers or raises the mint cap.
func UnsafeSetCap(cur realm, n int) {
	assertIsDevChain()
	supplyCap = n
}

// UnsafeSeedFor generates a seed for a specific gnome, with the current block time.
func UnsafeSeedFor(caller address, id, nonce int) string {
	assertIsDevChain()
	return generateSeed(caller, id, nonce)
}

// UnsafeMarkSeen marks packed traits as already minted, without minting them.
func UnsafeMarkSeen(cur realm, packed uint32) {
	assertIsDevChain()
	seenTraits.AddString(strconv.FormatUint(uint64(packed), 10))
}

// UnsafeSeenContains reports whether packed traits are marked as minted.
func UnsafeSeenContains(packed uint32) bool {
	assertIsDevChain()
	return seenTraits.ContainsString(strconv.FormatUint(uint64(packed), 10))
}

func assertIsDevChain() {
	id := runtime.ChainID()
	if id != "dev" && id != "tendermint_test" {
		panic("unauthorized")
	}
}
