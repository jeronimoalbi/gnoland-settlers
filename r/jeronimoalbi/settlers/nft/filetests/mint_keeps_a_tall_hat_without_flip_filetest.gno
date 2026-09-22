// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/mint_keeps_a_tall_hat_without_flip_filetest

// A tall hat that naturally comes out with the flip set is still minted, with the flip cleared (it has
// no effect on a tall hat, so it is not part of what makes a gnome unique).
package mint_keeps_a_tall_hat_without_flip_filetest

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

	height := int64(100)
	for {
		candidate := nft.NewTraits(settlers.UnsafeSeedFor(alice, height, 1, 0))
		if candidate.HatShape == 0 && candidate.Flip == 1 {
			break
		}

		height++
	}

	testing.SetHeight(height)
	testing.SetRealm(testing.NewUserRealm(alice))
	id := settlers.Mint(cross(cur), aliceProof)

	traits := settlers.TraitsOf(id)
	println("tall hat kept without flip:", traits.HatShape == 0 && traits.Flip == 0)
}

// Output:
// tall hat kept without flip: true
