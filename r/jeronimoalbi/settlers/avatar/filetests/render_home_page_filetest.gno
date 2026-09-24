// PKGPATH: gno.land/r/jeronimoalbi/settlers/avatar/filetests/render_home_page_filetest

package render_home_page_filetest

import "gno.land/r/jeronimoalbi/settlers/avatar"

func main() {
	println(avatar.Render(""))
}

// Output:
// # Settler avatars
// This realm draws a Settler as a picture give an address.
//
// It doesn't own the Settler, or store anything about it, it just looks one up and draws it, fresh, every time it's asked. That's on purpose, keeping the drawing separate from the main collection means any other realm or web app on Gno.land, a forum, a leaderboard, a profile page, can show a Settler next to an address without needing to understand pixel art, traits, or how any of it's put together.
//
// The [Settlers nft](/r/jeronimoalbi/settlers/nft) realm is still the one that actually mints the Settlers and keeps track of who owns what.
//
// Realm paths:
//
// | Path | Description |
// | --- | --- |
// | `svg/{address}` | The SVG of the Settler of an address. |
// | `md/{address}` | The Markdown that Markdown returns for an address, rendered, with the same parameters. |
//
// ## From a realm
// Call it directly from another realm, for example to show a Settler next to an address in your own `Render` function:
//
// ```go
// import "gno.land/r/jeronimoalbi/settlers/avatar"
//
// func RenderUser(addr address) string {
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
// With gnokey, from a terminal, save it straight to a file:
//
// ```sh
// gnokey query vm/qrender \
//   -remote <remote> \
//   -data "gno.land/r/jeronimoalbi/settlers/avatar:svg/{address}?size=256" \
//   | tail -n +2 | sed '1s/^data: //' > settler.svg
//
// ```
