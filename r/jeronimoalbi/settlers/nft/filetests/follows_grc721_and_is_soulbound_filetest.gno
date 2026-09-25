// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/follows_grc721_and_is_soulbound_filetest

// The realm has the GRC721 functions and a read-only GRC721 teller. The functions that would move a Settler
// or approve someone to move it always fail, from the realm and from the teller, so the owner never changes.
package follows_grc721_and_is_soulbound_filetest

import (
	"testing"

	"gno.land/p/nt/grc721/v0"
	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer     = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice        = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
	bob          = address("g1zzzunp8m6525h8na7spssnx9sqqq6dt2c5qwnu")
	fixtureRoot  = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
	fixtureTotal = 6
	aliceProof   = "3.2be7600330445ef373bea6dd657ddec83cdd81df5dec0c29dcff37a970b619fdf80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)
	nft.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)

	testing.SetRealm(testing.NewUserRealm(alice))
	tid := nft.Mint(cross(cur), aliceProof)

	var teller grc721.Teller = nft.Token()
	println("Canonical teller:", grc721.IsCanonicalTeller(teller))
	println("Name:", nft.GetName(), teller.GetName())
	println("Symbol:", nft.GetSymbol(), teller.GetSymbol())
	println("ID:", nft.ID(), teller.ID())
	println("Total supply:", nft.TotalSupply(), teller.TotalSupply())

	balance, err := nft.BalanceOf(alice)
	println("Balance of alice:", balance, err)
	owner, err := nft.OwnerOf(tid)
	println("Owner of", string(tid)+":", owner.String(), err)
	_, err = nft.OwnerOf("2")
	println("Owner of 2:", err)
	_, err = nft.GetApproved(tid)
	println("Approved:", err)
	println("Approved for all:", nft.IsApprovedForAll(alice, bob))

	// The owner tries every write of the standard, through the realm and through the teller.
	writes := []struct {
		name string
		fn   func()
	}{
		{"Approve", func() { nft.Approve(cross(cur), bob, tid) }},
		{"SetApprovalForAll", func() { nft.SetApprovalForAll(cross(cur), bob, true) }},
		{"TransferFrom", func() { nft.TransferFrom(cross(cur), alice, bob, tid) }},
	}
	for _, w := range writes {
		println(w.name+":", revive(w.fn))
	}

	println("Teller Approve:", teller.Approve(0, cur, bob, tid))
	println("Teller SetApprovalForAll:", teller.SetApprovalForAll(0, cur, bob, true))
	println("Teller TransferFrom:", teller.TransferFrom(0, cur, alice, bob, tid))

	owner, _ = nft.OwnerOf(tid)
	println("Owner after:", owner.String())
}

// Output:
// Canonical teller: true
// Name: Settlers Settlers
// Symbol: SETTLER SETTLER
// ID: gno.land/r/jeronimoalbi/settlers/nft.SETTLER.0000000 gno.land/r/jeronimoalbi/settlers/nft.SETTLER.0000000
// Total supply: 1 1
// Balance of alice: 1 undefined
// Owner of 1: g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 undefined
// Owner of 2: invalid token id
// Approved: token id not approved for anyone
// Approved for all: false
// Approve: settlers are soulbound, they can't be transferred or approved
// SetApprovalForAll: settlers are soulbound, they can't be transferred or approved
// TransferFrom: settlers are soulbound, they can't be transferred or approved
// Teller Approve: teller is readonly
// Teller SetApprovalForAll: teller is readonly
// Teller TransferFrom: teller is readonly
// Owner after: g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5
