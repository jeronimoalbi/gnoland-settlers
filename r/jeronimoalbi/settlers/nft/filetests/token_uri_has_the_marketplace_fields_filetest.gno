// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/token_uri_has_the_marketplace_fields_filetest

// TokenURI has the fields marketplaces and wallets read (OpenSea style), and external_url is the token page.
package token_uri_has_the_marketplace_fields_filetest

import (
	"strings"
	"testing"

	"gno.land/r/jeronimoalbi/settlers/nft"
)

const (
	deployer     = address("g1qqqqr2u6rfydqjkm56a7s54397vfp4kmvnuwev")
	alice        = address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5")
	fixtureRoot  = "057387f3d6e40789b4eb4cceed041278a98e98eae631f660ed92dae3b6e52d58"
	fixtureTotal = 6
	aliceProof   = "3.2be7600330445ef373bea6dd657ddec83cdd81df5dec0c29dcff37a970b619fdf80c3043ba1fa9eb2aaa8e4e1169bf3ff49d34b775c30ddb7ebcedfd6e30ef31a096a8a095aa594b5ecda85965cec0f68a4d2fd4e07b8a6d01ca4333e0bcb536"
	realmPath    = "/r/jeronimoalbi/settlers/nft"
)

func main(cur realm) {
	testing.SetRealm(testing.NewUserRealm(deployer))
	nft.UnsafeReset(cross(cur), deployer)
	nft.SetSnapshot(cross(cur), fixtureRoot, fixtureTotal)

	testing.SetRealm(testing.NewUserRealm(alice))
	nft.Mint(cross(cur), aliceProof)

	uri := nft.TokenURI(1)
	println("has the name:", strings.Contains(uri, `{"name":"Settler #1",`))
	println("has the image:", strings.Contains(uri, `"image":"data:image/svg+xml;charset=utf-8,%3Csvg`))
	println("has the external_url prefix:", strings.Contains(uri, `"external_url":"https://`))
	println("has the attributes:", strings.Contains(uri, `"attributes":[{"trait_type":"Skin","value":"`))

	link := nft.ExternalURL(1)
	println("external_url is the token page:", strings.HasSuffix(link, realmPath+":token/1"))
	println("uri has the same external_url:", strings.Contains(uri, `"external_url":"`+link+`"`))
}

// Output:
// has the name: true
// has the image: true
// has the external_url prefix: true
// has the attributes: true
// external_url is the token page: true
// uri has the same external_url: true
