// PKGPATH: gno.land/r/jeronimoalbi/settlers/avatar/filetests/render_markdown_page_rejects_invalid_addresses_filetest

// The md/{address} page rejects anything that is not a real address, and never echoes it back.
package render_markdown_page_rejects_invalid_addresses_filetest

import "gno.land/r/jeronimoalbi/settlers/avatar"

func main() {
	inputs := []string{"www.evil.com", "g1short", "G1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5", "x`y", "<b>x", "[click](evil.com)"}
	for _, input := range inputs {
		println(input+":", avatar.Render("md/"+input))
	}
}

// Output:
// www.evil.com: Not a valid address.
//
// [\< Home](/r/jeronimoalbi/settlers/avatar)
//
//
// g1short: Not a valid address.
//
// [\< Home](/r/jeronimoalbi/settlers/avatar)
//
//
// G1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5: Not a valid address.
//
// [\< Home](/r/jeronimoalbi/settlers/avatar)
//
//
// x`y: Not a valid address.
//
// [\< Home](/r/jeronimoalbi/settlers/avatar)
//
//
// <b>x: Not a valid address.
//
// [\< Home](/r/jeronimoalbi/settlers/avatar)
//
//
// [click](evil.com): Not a valid address.
//
// [\< Home](/r/jeronimoalbi/settlers/avatar)
