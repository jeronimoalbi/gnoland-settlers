// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/render_token_not_found_filetest

// The token page says "not found" for an id that is 0, out of range, or not a number.
package render_token_not_found_filetest

import (
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer     = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice        = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
	fixtureRoot  = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
	fixtureTotal = 6
	aliceProof   = "3.2be7600330445ef373bea6dd657ddec83cdd81df5dec0c29dcff37a970b619fdf80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)
	nft.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)

	testing.SetRealm(testing.NewUserRealm(alice))
	nft.Mint(cross(cur), aliceProof)

	for _, path := range []string{"token/0", "token/2", "token/abc"} {
		println(path+":", nft.Render(path))
	}
}

// Output:
// token/0: Settler not found.
//
// [\< Home](/r/jeronimoalbi/settlers/nft)
//
//
// token/2: Settler not found.
//
// [\< Home](/r/jeronimoalbi/settlers/nft)
//
//
// token/abc: Settler not found.
//
// [\< Home](/r/jeronimoalbi/settlers/nft)
