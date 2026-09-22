// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/mint_names_signer_when_proof_invalid_filetest

// When a proof does not match the signer, the abort names the account that signed, not the proof's owner.
package mint_names_signer_when_proof_invalid_filetest

import (
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer     = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice        = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
	fixtureRoot  = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
	fixtureTotal = 6
	otherProof   = "4.f46f7d4d2b0b31ae2533ce0c72a96db22eb097bc5cafb251d3ec59d1e446e7f622d6ca3090ef47870c1a0ef51fe1e13e7790b259ac55e52fec5d5d78d7c35490"
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)
	nft.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)

	testing.SetRealm(testing.NewUserRealm(alice))
	nft.Mint(cross(cur), otherProof)
}

// Error:
// the proof is not valid for this account: g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5
