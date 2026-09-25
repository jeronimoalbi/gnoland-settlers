// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/mint_adds_the_gnome_to_the_filter_filetest

// After a mint, the gnome it produced is recorded, so a later mint would not repeat it.
package mint_adds_the_gnome_to_the_filter_filetest

import (
	"testing"

	"gno.land/p/jeronimoalbi/settlers/nft/v0"
	settlers "gno.land/r/jeronimoalbi/settlers/nft"
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
	settlers.UnsafeReset(cross(cur), deployer)
	settlers.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)

	testing.SetRealm(testing.NewUserRealm(alice))
	id := settlers.Mint(cross(cur), aliceProof)

	traits, _ := settlers.TraitsOf(id)
	packed := nft.Pack(traits)
	println("The filter has the gnome:", settlers.UnsafeSeenContains(packed))
}

// Output:
// The filter has the gnome: true
