// PKGPATH: gno.land/r/jeronimoalbi/settlers/avatar/filetests/notice_can_be_set_and_cleared_filetest

// The admin can post a realm-wide notice at any time, and clear it again.
package notice_can_be_set_and_cleared_filetest

import (
	"testing"

	"gno.land/p/nt/mdalert/v0"
	"gno.land/r/jeronimoalbi/settlers/avatar"
)

const deployer = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	avatar.UnsafeSetAdmin(cross(cur), deployer)

	println("Notice before:", avatar.Notice)
	println("Notice type before:", string(avatar.NoticeType))

	avatar.SetNotice(cross(cur), mdalert.TypeWarning, "Something is wrong, see the README.")
	println("Notice after set:", avatar.Notice)
	println("Notice type after set:", string(avatar.NoticeType))

	avatar.ClearNotice(cross(cur))
	println("Notice after clear:", avatar.Notice)
	println("Notice type after clear:", string(avatar.NoticeType))
}

// Output:
// Notice before:
// Notice type before:
// Notice after set: Something is wrong, see the README.
// Notice type after set: WARNING
// Notice after clear:
// Notice type after clear:
