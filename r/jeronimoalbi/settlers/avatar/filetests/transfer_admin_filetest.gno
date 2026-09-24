// PKGPATH: gno.land/r/jeronimoalbi/settlers/avatar/filetests/transfer_admin_filetest

// Only the admin can make another account the admin, the new account must be valid, and the old admin
// loses its rights.
package transfer_admin_filetest

import (
	"testing"

	"gno.land/p/nt/mdalert/v0"
	"gno.land/r/jeronimoalbi/settlers/avatar"
)

const (
	deployer = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice    = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	avatar.UnsafeSetAdmin(cross(cur), deployer)
	println("Admin:", avatar.Admin().String())

	testing.SetRealm(testing.NewUserRealm(alice))
	if err := revive(func() { avatar.TransferAdmin(cross(cur), alice) }); err != nil {
		println("Abort:", err)
	}

	testing.SetRealm(testing.NewUserRealm(deployer))
	if err := revive(func() { avatar.TransferAdmin(cross(cur), address("invalid")) }); err != nil {
		println("Abort:", err)
	}

	avatar.TransferAdmin(cross(cur), alice)
	println("Admin:", avatar.Admin().String())

	if err := revive(func() { avatar.ClearNotice(cross(cur)) }); err != nil {
		println("Abort:", err)
	}

	testing.SetRealm(testing.NewUserRealm(alice))
	avatar.SetNotice(cross(cur), mdalert.TypeInfo, "Hello.")
	println("Notice:", avatar.Notice)
}

// Output:
// Admin: g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev
// Abort: ownable: caller is not owner
// Abort: ownable: new owner address is invalid
// Admin: g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5
// Abort: ownable: caller is not owner
// Notice: Hello.
