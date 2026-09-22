// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/mint_stops_at_the_cap_filetest

// Once the cap is reached, no more Settlers can be minted, and nothing changes for the rejected caller.
package mint_stops_at_the_cap_filetest

import (
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer     = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice        = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
	first        = address("g100000aeu2lh0jrrnmn2npc88typ25u7t7ejr8g")
	fixtureRoot  = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
	fixtureTotal = 6
	firstProof   = "0.5bfc678bc7a53e301501fbc5893c7a39f6836905bf0e35944ca0717cfdfd5aa22c31a545dd5ad94140b3de0b45b90cc561a6a7283c5d7436ed651aa2201f196fa096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"
	aliceProof   = "3.2be7600330445ef373bea6dd657ddec83cdd81df5dec0c29dcff37a970b619fdf80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)
	nft.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)
	nft.UnsafeSetCap(cross(cur), 1)

	testing.SetRealm(testing.NewUserRealm(first))
	nft.Mint(cross(cur), firstProof)

	testing.SetRealm(testing.NewUserRealm(alice))
	if err := revive(func() {
		nft.Mint(cross(cur), aliceProof)
	}); err != nil {
		println("abort:", err)
	}

	println("total supply:", nft.TotalSupply())
	println("token of alice:", nft.TokenOf(alice))
}

// Output:
// abort: sold out
// total supply: 1
// token of alice: 0
