// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/set_snapshot_can_be_corrected_before_first_mint_filetest

// The owner can call SetSnapshot again to fix a mistake, as long as nothing was minted yet.
package set_snapshot_can_be_corrected_before_first_mint_filetest

import (
	"strings"
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer     = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	fixtureRoot  = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
	fixtureTotal = 6
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)
	nft.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)

	otherRoot := strings.Repeat("ab", 32)
	nft.SetSnapshot(cross(cur), otherRoot, 7)

	println("Root:", nft.MerkleRoot())
	println("Total:", nft.Total())
}

// Output:
// Root: abababababababababababababababababababababababababababababababab
// Total: 7
