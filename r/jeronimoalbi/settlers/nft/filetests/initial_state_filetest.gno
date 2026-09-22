// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/initial_state_filetest

// A fresh deploy has no snapshot and nothing minted yet.
package initial_state_filetest

import (
	"gno.land/r/jeronimoalbi/settlers/nft"
)

func main() {
	println("root:", nft.Root())
	println("total:", nft.Total())
	println("supply:", nft.TotalSupply())
	println("cap:", nft.Cap())
}

// Output:
// root:
// total: 0
// supply: 0
// cap: 3000
