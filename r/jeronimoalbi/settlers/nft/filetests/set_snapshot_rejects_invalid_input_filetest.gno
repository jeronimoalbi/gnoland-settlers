// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/set_snapshot_rejects_invalid_input_filetest

// SetSnapshot rejects a root that is not 32 bytes of hex, and an empty list of accounts.
package set_snapshot_rejects_invalid_input_filetest

import (
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer    = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	fixtureRoot = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
)

func main(cur realm) {
	tests := []struct {
		name  string
		root  string
		count int
	}{
		{"Root too short", "abcd", 6},
		{"Root not hex", "zz" + fixtureRoot[2:], 6},
		{"No accounts", fixtureRoot, 0},
	}

	for _, tc := range tests {
		testing.SetRealm(testing.NewUserRealm(deployer))
		nft.UnsafeReset(cross(cur), deployer)

		if err := revive(func() {
			nft.SetSnapshot(cross(cur), tc.root, tc.count)
		}); err != nil {
			println(tc.name+":", err)
		}

		println(tc.name+", root after:", nft.MerkleRoot())
	}
}

// Output:
// Root too short: the root must be 32 bytes in hex
// Root too short, root after:
// Root not hex: the root must be 32 bytes in hex
// Root not hex, root after:
// No accounts: the list must have at least one account
// No accounts, root after:
