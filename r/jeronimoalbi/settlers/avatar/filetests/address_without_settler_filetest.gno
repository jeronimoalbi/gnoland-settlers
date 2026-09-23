// PKGPATH: gno.land/r/jeronimoalbi/settlers/avatar/filetests/address_without_settler_filetest

// An address that never minted a Settler gets an empty SVG, URI and Markdown.
package address_without_settler_filetest

import "gno.land/r/jeronimoalbi/settlers/avatar"

const nobody = address("g172aaqt6g99t8u9dr90whfstrm9j6jdvjt6whh5")

func main() {
	println("SVG:", avatar.SVG(nobody, 64, false))
	println("URI:", avatar.URI(nobody, 64, false))
	println("Markdown:", avatar.Markdown(nobody, 64, false))
}

// Output:
// SVG:
// URI:
// Markdown:
