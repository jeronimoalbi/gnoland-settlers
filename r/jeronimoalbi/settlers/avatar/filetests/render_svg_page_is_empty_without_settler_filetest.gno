// PKGPATH: gno.land/r/jeronimoalbi/settlers/avatar/filetests/render_svg_page_is_empty_without_settler_filetest

// The svg/{address} page has nothing to draw for an address without a Settler.
package render_svg_page_is_empty_without_settler_filetest

import "gno.land/r/jeronimoalbi/settlers/avatar"

const nobody = address("g172aaqt6g99t8u9dr90whfstrm9j6jdvjt6whh5")

func main() {
	println(avatar.Render("svg/" + nobody.String()))
}

// Output:
