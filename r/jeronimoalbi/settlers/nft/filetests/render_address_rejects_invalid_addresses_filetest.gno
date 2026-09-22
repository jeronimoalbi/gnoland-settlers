// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/render_address_rejects_invalid_addresses_filetest

// The addr/{address} page rejects anything that is not a real address, and never echoes it back.
package render_address_rejects_invalid_addresses_filetest

import (
	"strings"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

func main() {
	inputs := []string{"www.evil.com", "g1short", "G1JG8MTUTU9KHHFWC4NXMUHCPFTF0PAJDHFVSQF5", "x`y", "<b>x", "[click](evil.com)"}
	for _, input := range inputs {
		page := nft.Render("addr/" + input)
		rejected := strings.Contains(page, "Not a valid address.")
		echoed := strings.Contains(page, input)
		println(input, "rejected:", rejected, "echoed:", echoed)
	}
}

// Output:
// www.evil.com rejected: true echoed: false
// g1short rejected: true echoed: false
// G1JG8MTUTU9KHHFWC4NXMUHCPFTF0PAJDHFVSQF5 rejected: true echoed: false
// x`y rejected: true echoed: false
// <b>x rejected: true echoed: false
// [click](evil.com) rejected: true echoed: false
