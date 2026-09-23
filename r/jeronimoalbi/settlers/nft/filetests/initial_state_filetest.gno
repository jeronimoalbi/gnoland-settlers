// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/initial_state_filetest

// A fresh deploy has no snapshot and nothing minted yet.
package initial_state_filetest

import (
	"gno.land/r/jeronimoalbi/settlers/nft"
)

func main() {
	println("Root:", nft.MerkleRoot())
	println("Total:", nft.Total())
	println("Supply:", nft.TotalSupply())
	println("Cap:", nft.Cap())
}

// Output:
// Root:
// Total: 0
// Supply: 0
// Cap: 3000
