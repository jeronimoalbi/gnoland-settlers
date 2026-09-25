// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/traits_of_unknown_token_fails_filetest

// Asking for the traits of a token ID that was never minted, or that is not canonical, fails.
package traits_of_unknown_token_fails_filetest

import (
	"gno.land/p/nt/grc721/v0"
	"gno.land/r/jeronimoalbi/settlers/nft"
)

func main() {
	for _, tid := range []grc721.TokenID{"7", "01", "+1", "", "abc"} {
		_, err := nft.TraitsOf(tid)
		println(string(tid)+":", err)
	}
}

// Output:
// 7: invalid token id
// 01: invalid token id
// +1: invalid token id
// : invalid token id
// abc: invalid token id
