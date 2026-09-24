// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/notice_rejects_invalid_types_filetest

// A notice type that is not one of the mdalert types is rejected, so it can't inject Markdown into the
// alert header, and an empty type can't hide a notice.
package notice_rejects_invalid_types_filetest

import (
	"testing"

	"gno.land/p/nt/mdalert/v0"
	"gno.land/r/jeronimoalbi/settlers/nft"
)

const deployer = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)

	for _, alertType := range []mdalert.Type{"NOTE]\n\n# Injected", "", "note"} {
		if err := revive(func() {
			nft.SetNotice(cross(cur), alertType, "Something is wrong.")
		}); err != nil {
			println("Abort:", err)
		}
	}

	println("Notice:", nft.Notice)
	println("Notice type:", string(nft.NoticeType))
}

// Output:
// Abort: invalid notice type
// Abort: invalid notice type
// Abort: invalid notice type
// Notice:
// Notice type:
