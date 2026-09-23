// PKGPATH: gno.land/r/jeronimoalbi/settlers/avatar/filetests/render_markdown_page_filetest

package render_markdown_page_filetest

import "gno.land/r/jeronimoalbi/settlers/avatar"

const nobody = address("g172aaqt6g99t8u9dr90whfstrm9j6jdvjt6whh5")

func main() {
	println(avatar.Render("md/" + nobody.String() + "?size=64"))
}

// Output:
// # Avatar of `g172aaqt6g99t8u9dr90whfstrm9j6jdvjt6whh5`
//
//
// [Home](/r/jeronimoalbi/settlers/avatar)
