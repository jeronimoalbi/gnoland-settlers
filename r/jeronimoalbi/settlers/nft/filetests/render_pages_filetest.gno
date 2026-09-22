// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/render_pages_filetest

// The home page shows the mint state and the last Settlers; the token and address pages show one Settler.
package render_pages_filetest

import (
	"strings"
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer     = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice        = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
	bob          = address("g1wymu47drhr0kuq2098m792lytgtj2nyx77yrsm")
	notEligible  = address("g172aaqt6g99t8u9dr90whfstrm9j6jdvjt6whh5")
	fixtureRoot  = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
	fixtureTotal = 6
	aliceProof   = "3.2be7600330445ef373bea6dd657ddec83cdd81df5dec0c29dcff37a970b619fdf80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"
	bobProof     = "4.f46f7d4d2b0b31ae2533ce0c72a96db22eb097bc5cafb251d3ec59d1e446e7f622d6ca3090ef47870c1a0ef51fe1e13e7790b259ac55e52fec5d5d78d7c35490"
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)
	nft.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)

	testing.SetRealm(testing.NewUserRealm(alice))
	nft.Mint(cross(cur), aliceProof)
	testing.SetRealm(testing.NewUserRealm(bob))
	nft.Mint(cross(cur), bobProof)

	tests := []struct {
		name  string
		path  string
		wants []string
	}{
		{"home", "", []string{
			"# Settlers", "**Minted:** 2 of 3000", "**Eligible accounts:** 6", fixtureRoot,
			"## Last Settlers", "![Settler #2](data:image/svg+xml", "(/r/jeronimoalbi/settlers/nft:token/2)",
		}},
		{"token", "token/2", []string{
			"# Settler #2", "data:image/svg+xml", "| Skin |", "| Background |", string(bob), "soulbound",
		}},
		{"address with a token", "addr/" + string(alice), []string{"Settler #1", ":token/1"}},
		{"address without a token", "addr/" + string(notEligible), []string{"has not minted"}},
		{"path not found", "foo/bar/baz", []string{"Path not found"}},
	}

	for _, tc := range tests {
		page := nft.Render(tc.path)
		ok := true
		for _, want := range tc.wants {
			if !strings.Contains(page, want) {
				ok = false
			}
		}

		println(tc.name+":", ok)
	}
}

// Output:
// home: true
// token: true
// address with a token: true
// address without a token: true
// path not found: true
