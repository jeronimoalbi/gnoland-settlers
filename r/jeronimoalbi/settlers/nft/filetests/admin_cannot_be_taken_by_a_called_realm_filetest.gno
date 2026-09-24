// PKGPATH: gno.land/r/test/evil

// When the admin calls a function of another realm, that realm can't use the call to act as the admin:
// in the nft realm the caller is the other realm, not the admin.
package evil

import (
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	attacker = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
)

// Innocent looks like any other function the admin could call, for example to claim an airdrop.
func Innocent(cur realm) {
	if err := revive(func() { nft.TransferAdmin(cross(cur), attacker) }); err != nil {
		println("Abort:", err)
	}
}

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)

	// The admin signs a transaction that calls this realm.
	Innocent(cross(cur))
	println("Admin:", nft.Admin().String())
}

// Output:
// Abort: ownable: caller is not owner
// Admin: g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev
