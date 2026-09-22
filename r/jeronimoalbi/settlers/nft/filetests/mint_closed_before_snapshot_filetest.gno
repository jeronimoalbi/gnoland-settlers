// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/mint_closed_before_snapshot_filetest

// Minting before the owner has opened the mint (no snapshot set) always aborts, whatever the proof.
package mint_closed_before_snapshot_filetest

import (
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const alice = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(alice))
	nft.Mint(cross(cur), "3.2be7600330445ef373bea6dd657ddec83cdd81df5dec0c29dcff37a970b619fdf80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536")
}

// Error:
// the mint is not open yet
