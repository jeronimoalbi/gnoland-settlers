// PKGPATH: gno.land/r/jeronimoalbi/settlers/avatar/filetests/render_home_page_filetest

package render_home_page_filetest

import "gno.land/r/jeronimoalbi/settlers/avatar"

func main() {
	println(avatar.Render(""))
}

// Output:
// # Settler avatars
// The [Settlers](/r/jeronimoalbi/settlers/nft) of an address as an avatar, for other realms and for web apps.
//
// ## From a realm
// ```go
// import "gno.land/r/jeronimoalbi/settlers/avatar"
//
// func row(addr address) string {
// 	return avatar.Markdown(addr, 32, true) + " " + addr.String()
// }
//
// ```
// | Function | Description |
// | --- | --- |
// | Markdown(addr, size, transparent) | The image, or an empty text if there is none |
// | SVG(addr, size, transparent) | The SVG document, or an empty text if there is none |
// | URI(addr, size, transparent) | The same image as a data URI |
//
// The size is in pixels, from 32 to 2048, and 0 leaves it to the container. With transparent the image has no background. Every call draws the image again and costs gas (about 6 to 8 million), so use it in `Render` and not in a transaction.
//
// ## From a web app
// Ask the node for the page of an address, with `vm/qrender`, and use what it returns as an image: `/r/jeronimoalbi/settlers/avatar:svg/{address}?size=64&transparent=1`. It is empty if the address has no Settler.
//
