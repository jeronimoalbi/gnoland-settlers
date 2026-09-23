// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/set_snapshot_only_owner_filetest

// A caller that is not the owner cannot open the mint.
package set_snapshot_only_owner_filetest

import (
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const alice = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(alice))

	if err := revive(func() {
		nft.SetSnapshot(cross(cur), "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58", 6)
	}); err != nil {
		println("Abort:", err)
	}

	println("Root:", nft.MerkleRoot())
}

// Output:
// Abort: ownable: caller is not owner
// Root:
