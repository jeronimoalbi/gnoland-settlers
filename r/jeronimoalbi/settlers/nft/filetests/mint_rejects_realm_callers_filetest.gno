// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/mint_rejects_realm_callers_filetest

// A realm can't mint a Settler, even when the mint is open, only user accounts can.
package mint_rejects_realm_callers_filetest

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

	testing.SetRealm(testing.NewCodeRealm("gno.land/r/test/minter"))
	nft.Mint(cross(cur), "0.00")
}

// Error:
// only user accounts can mint
