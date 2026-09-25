// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/mint_emits_the_grc721_events_filetest

// The collection is announced with the GRC721 NewToken event and each mint with a Transfer event from the
// empty address, emitted by the GRC721 package itself.
package mint_emits_the_grc721_events_filetest

import (
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer     = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice        = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
	fixtureRoot  = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
	fixtureTotal = 6
	aliceProof   = "3.2be7600330445ef373bea6dd657ddec83cdd81df5dec0c29dcff37a970b619fdf80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)
	nft.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)

	testing.SetRealm(testing.NewUserRealm(alice))
	nft.Mint(cross(cur), aliceProof)
}

// Events:
// [
//   {
//     "type": "NewToken",
//     "attrs": [
//       {
//         "key": "token",
//         "value": "gno.land/r/jeronimoalbi/settlers/nft.SETTLER.0000000"
//       },
//       {
//         "key": "name",
//         "value": "Settlers"
//       },
//       {
//         "key": "symbol",
//         "value": "SETTLER"
//       }
//     ],
//     "pkg_path": "gno.land/p/nt/grc721/v0"
//   },
//   {
//     "type": "SnapshotSet",
//     "attrs": [
//       {
//         "key": "root",
//         "value": "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
//       },
//       {
//         "key": "total",
//         "value": "6"
//       }
//     ],
//     "pkg_path": "gno.land/r/jeronimoalbi/settlers/nft"
//   },
//   {
//     "type": "Transfer",
//     "attrs": [
//       {
//         "key": "token",
//         "value": "gno.land/r/jeronimoalbi/settlers/nft.SETTLER.0000000"
//       },
//       {
//         "key": "from",
//         "value": ""
//       },
//       {
//         "key": "to",
//         "value": "g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5"
//       },
//       {
//         "key": "tokenId",
//         "value": "1"
//       }
//     ],
//     "pkg_path": "gno.land/p/nt/grc721/v0"
//   }
// ]
