// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/mint_rejects_invalid_proofs_filetest

// Mint rejects a proof that does not belong to the caller, is out of range, or is malformed, and nothing
// is minted when it does.
package mint_rejects_invalid_proofs_filetest

import (
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer     = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice        = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
	notEligible  = address("g172aaqt6g99t8u9dr90whfstrm9j6jdvjt6whh5")
	fixtureRoot  = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
	fixtureTotal = 6
	proof        = "3.2be7600330445ef373bea6dd657ddec83cdd81df5dec0c29dcff37a970b619fdf80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"
	otherProof   = "4.f46f7d4d2b0b31ae2533ce0c72a96db22eb097bc5cafb251d3ec59d1e446e7f622d6ca3090ef47870c1a0ef51fe1e13e7790b259ac55e52fec5d5d78d7c35490"
)

func main(cur realm) {
	tests := []struct {
		name   string
		caller address
		proof  string
	}{
		{"proof of another account", alice, otherProof},
		{"account outside the list", notEligible, proof},
		{"wrong index", alice, "2" + proof[1:]},
		{"missing dot", alice, "abc"},
		{"index not a number", alice, "x" + proof[1:]},
		{"index out of range", alice, "9" + proof[1:]},
		{"hash of the wrong size", alice, "3.abcd"},
		{"aunts not hex", alice, "3.zz"},
	}

	for _, tc := range tests {
		testing.SetRealm(testing.NewUserRealm(deployer))
		nft.UnsafeReset(cross(cur), deployer)
		nft.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)

		testing.SetRealm(testing.NewUserRealm(tc.caller))
		if err := revive(func() {
			nft.Mint(cross(cur), tc.proof)
		}); err != nil {
			println(tc.name+":", err)
		}

		println(tc.name+", total supply:", nft.TotalSupply())
	}
}

// Output:
// proof of another account: the proof is not valid for this account: g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5
// proof of another account, total supply: 0
// account outside the list: the proof is not valid for this account: g172aaqt6g99t8u9dr90whfstrm9j6jdvjt6whh5
// account outside the list, total supply: 0
// wrong index: the proof is not valid for this account: g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5
// wrong index, total supply: 0
// missing dot: the proof must be <index>.<aunts>
// missing dot, total supply: 0
// index not a number: the index of the proof is not valid
// index not a number, total supply: 0
// index out of range: the index of the proof is not valid
// index out of range, total supply: 0
// hash of the wrong size: the aunts of the proof must be hashes of 32 bytes in hex
// hash of the wrong size, total supply: 0
// aunts not hex: the aunts of the proof must be hashes of 32 bytes in hex
// aunts not hex, total supply: 0
