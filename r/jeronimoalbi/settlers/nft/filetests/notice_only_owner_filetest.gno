// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/notice_only_owner_filetest

// A caller that is not the admin cannot post a notice.
package notice_only_owner_filetest

import (
	"testing"

	"gno.land/p/nt/mdalert/v0"
	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice    = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)

	testing.SetRealm(testing.NewUserRealm(alice))
	if err := revive(func() {
		nft.SetNotice(cross(cur), mdalert.TypeWarning, "Something is wrong.")
	}); err != nil {
		println("Abort:", err)
	}

	println("Notice:", nft.Notice)
	println("Notice type:", string(nft.NoticeType))
}

// Output:
// Abort: ownable: caller is not owner
// Notice:
// Notice type:
