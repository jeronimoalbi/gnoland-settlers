// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/traits_of_unknown_token_panics_filetest

// Asking for the traits of a token id that was never minted panics.
package traits_of_unknown_token_panics_filetest

import "gno.land/r/jeronimoalbi/settlers/nft"

func main() {
	nft.TraitsOf(7)
}

// Error:
// token not found
