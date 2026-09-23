// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/render_address_rejects_invalid_addresses_filetest

// The addr/{address} page rejects anything that is not a real address, and never echoes it back.
package render_address_rejects_invalid_addresses_filetest

import "gno.land/r/jeronimoalbi/settlers/nft"

func main() {
	inputs := []string{"www.evil.com", "g1short", "G1JG8MTUTU9KHHFWC4NXMUHCPFTF0PAJDHFVSQF5", "x`y", "<b>x", "[click](evil.com)"}
	for _, input := range inputs {
		println(input+":", nft.Render("addr/"+input))
	}
}

// Output:
// www.evil.com: Not a valid address.
//
// [Home](/r/jeronimoalbi/settlers/nft)
//
//
// g1short: Not a valid address.
//
// [Home](/r/jeronimoalbi/settlers/nft)
//
//
// G1JG8MTUTU9KHHFWC4NXMUHCPFTF0PAJDHFVSQF5: Not a valid address.
//
// [Home](/r/jeronimoalbi/settlers/nft)
//
//
// x`y: Not a valid address.
//
// [Home](/r/jeronimoalbi/settlers/nft)
//
//
// <b>x: Not a valid address.
//
// [Home](/r/jeronimoalbi/settlers/nft)
//
//
// [click](evil.com): Not a valid address.
//
// [Home](/r/jeronimoalbi/settlers/nft)
