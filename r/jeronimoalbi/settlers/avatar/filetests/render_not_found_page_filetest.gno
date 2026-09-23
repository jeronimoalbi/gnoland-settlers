// PKGPATH: gno.land/r/jeronimoalbi/settlers/avatar/filetests/render_not_found_page_filetest

package render_not_found_page_filetest

import "gno.land/r/jeronimoalbi/settlers/avatar"

func main() {
	println(avatar.Render("foo/bar/baz"))
}

// Output:
// Path not found
