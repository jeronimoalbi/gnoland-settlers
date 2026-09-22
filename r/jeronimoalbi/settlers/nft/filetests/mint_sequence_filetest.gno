// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/mint_sequence_filetest

// Several accounts mint in order: ids follow the mint order, the first account gets its own token, and
// every gnome is different (Mint never repeats one, even across different accounts and seeds).
package mint_sequence_filetest

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
)

var accounts = []struct {
	addr  address
	proof string
}{
	{"g100000aeu2lh0jrrnmn2npc88typ25u7t7ejr8g", "0.5bfc678bc7a53e301501fbc5893c7a39f6836905bf0e35944ca0717cfdfd5aa22c31a545dd5ad94140b3de0b45b90cc561a6a7283c5d7436ed651aa2201f196fa096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"},
	{"g1aeddlftlfk27ret5rf750d7w5dume3kcsm8r8m", "1.e3bdbd8dde2b8da05ce1d24cda958219fbcd0b78fa79d22a1533f46a7817477d2c31a545dd5ad94140b3de0b45b90cc561a6a7283c5d7436ed651aa2201f196fa096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"},
	{"g1j0rwgzam8a30skv638y20mpkhwpwzsulnqfmvg", "2.62833b5ed562f833b9fdf636821adc3afd923e935b2351e98e011ffcabc4e20ff80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"},
	{alice, "3.2be7600330445ef373bea6dd657ddec83cdd81df5dec0c29dcff37a970b619fdf80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"},
	{"g1wymu47drhr0kuq2098m792lytgtj2nyx77yrsm", "4.f46f7d4d2b0b31ae2533ce0c72a96db22eb097bc5cafb251d3ec59d1e446e7f622d6ca3090ef47870c1a0ef51fe1e13e7790b259ac55e52fec5d5d78d7c35490"},
	{"g1zzzunp8m6525h8na7spssnx9sqqq6dt2c5qwnu", "5.39455f15e06f8981c23484970664b49293a3e56eb934e397bc2b09e6910fdd6522d6ca3090ef47870c1a0ef51fe1e13e7790b259ac55e52fec5d5d78d7c35490"},
}

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	settlers.UnsafeReset(cross(cur), deployer)
	settlers.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)

	seenGnomes := map[nft.Traits]bool{}
	for i, account := range accounts {
		testing.SetRealm(testing.NewUserRealm(account.addr))
		id := settlers.Mint(cross(cur), account.proof)
		if id != i+1 {
			println("wrong id for account", i, ":", id)
		}

		seenGnomes[settlers.TraitsOf(id)] = true
	}

	// alice is accounts[3], so she is the 4th to mint and gets token id 4.
	println("total supply:", settlers.TotalSupply())
	println("owner of alice's token:", settlers.OwnerOf(settlers.TokenOf(alice)) == alice)
	println("balance of alice:", settlers.BalanceOf(alice))
	println("token of alice:", settlers.TokenOf(alice))
	println("every gnome different:", len(seenGnomes) == len(accounts))
}

// Output:
// total supply: 6
// owner of alice's token: true
// balance of alice: 1
// token of alice: 4
// every gnome different: true
