// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/set_snapshot_stores_root_and_total_filetest

// The owner opens the mint by setting the Merkle root and the number of eligible accounts.
package set_snapshot_stores_root_and_total_filetest

import (
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

	println("Root:", nft.MerkleRoot())
	println("Total:", nft.Total())
}

// Output:
// Root: 057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58
// Total: 6
