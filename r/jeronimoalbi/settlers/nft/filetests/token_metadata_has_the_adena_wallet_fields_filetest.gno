// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/token_metadata_has_the_adena_wallet_fields_filetest

// TokenMetadata has the fields the Adena wallet reads
package token_metadata_has_the_adena_wallet_fields_filetest

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

	meta, err := nft.TokenMetadata("1")
	println("Token metadata:", meta, err)

	_, err = nft.TokenMetadata("2")
	println("Token metadata of an unknown token:", err)
}

// Output:
// Token metadata: {"name":"Settler #1","description":"Soulbound gnome of the early settlers of Gno.land. The art of the Settlers is dedicated to the public domain under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)","image":"data:image/svg+xml;charset=utf-8,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20viewBox=%22-4%200%2032%2032%22%20width=%22512%22%20height=%22512%22%20shape-rendering=%22crispEdges%22%3E%3Crect%20x=%22-4%22%20width=%2232%22%20height=%2232%22%20fill=%22%23dbeed2%22/%3E%3Cpath%20fill=%22%232a1a2e%22%20d=%22M9%200h4v1h-4zM8%201h1v1h-1zM13%201h1v1h-1zM7%202h1v1h-1zM10%202h1v1h-1zM13%202h1v1h-1zM7%203h1v1h-1zM9%203h2v1h-2zM13%203h1v1h-1zM8%204h2v1h-2zM14%204h1v1h-1zM9%205h1v1h-1zM14%205h1v1h-1zM8%206h1v1h-1zM15%206h1v1h-1zM8%207h1v1h-1zM15%207h1v1h-1zM7%208h1v1h-1zM16%208h1v1h-1zM7%209h1v1h-1zM16%209h1v1h-1zM6%2010h1v1h-1zM17%2010h1v1h-1zM4%2011h1v1h-1zM19%2011h1v1h-1zM4%2012h1v1h-1zM19%2012h1v1h-1zM6%2013h1v1h-1zM17%2013h1v1h-1zM6%2014h1v1h-1zM17%2014h1v1h-1zM5%2015h1v1h-1zM18%2015h1v1h-1zM4%2016h1v1h-1zM19%2016h1v1h-1zM6%2017h1v1h-1zM17%2017h1v1h-1zM5%2018h1v1h-1zM18%2018h1v1h-1zM4%2019h2v1h-2zM18%2019h2v1h-2zM3%2020h1v1h-1zM5%2020h1v1h-1zM18%2020h1v1h-1zM20%2020h1v1h-1zM3%2021h1v1h-1zM6%2021h1v1h-1zM17%2021h1v1h-1zM20%2021h1v1h-1zM3%2022h1v1h-1zM6%2022h1v1h-1zM17%2022h1v1h-1zM20%2022h1v1h-1zM2%2023h1v1h-1zM7%2023h1v1h-1zM16%2023h1v1h-1zM21%2023h1v1h-1zM2%2024h1v1h-1zM7%2024h1v1h-1zM16%2024h1v1h-1zM21%2024h1v1h-1zM3%2025h1v1h-1zM8%2025h1v1h-1zM15%2025h1v1h-1zM20%2025h1v1h-1zM3%2026h1v1h-1zM9%2026h1v1h-1zM14%2026h1v1h-1zM20%2026h1v1h-1zM3%2027h1v1h-1zM10%2027h1v1h-1zM13%2027h1v1h-1zM20%2027h1v1h-1zM5%2028h1v1h-1zM11%2028h2v1h-2zM18%2028h1v1h-1zM5%2029h1v1h-1zM11%2029h2v1h-2zM18%2029h1v1h-1zM5%2030h1v1h-1zM11%2030h2v1h-2zM18%2030h1v1h-1zM5%2031h14v1h-14z%22/%3E%3Cpath%20fill=%22%237ed36a%22%20d=%22M9%201h1v1h-1zM8%203h1v1h-1zM11%203h1v1h-1zM10%205h1v1h-1zM9%207h1v1h-1zM8%209h1v1h-1zM5%2011h1v1h-1z%22/%3E%3Cpath%20fill=%22%232e7a3a%22%20d=%22M10%201h1v1h-1zM12%201h1v1h-1zM9%202h1v1h-1zM12%202h1v1h-1zM12%203h1v1h-1zM13%204h1v1h-1zM13%205h1v1h-1zM14%206h1v1h-1zM14%207h1v1h-1zM15%208h1v1h-1zM15%209h1v1h-1zM8%2010h9v1h-9zM18%2011h1v1h-1zM5%2012h14v1h-14z%22/%3E%3Cpath%20fill=%22%234aa84a%22%20d=%22M11%201h1v1h-1zM8%202h1v1h-1zM11%202h1v1h-1zM10%204h3v1h-3zM11%205h2v1h-2zM9%206h5v1h-5zM10%207h4v1h-4zM8%208h7v1h-7zM9%209h6v1h-6zM7%2010h1v1h-1zM6%2011h12v1h-12z%22/%3E%3Cpath%20fill=%22%23b57650%22%20d=%22M7%2013h10v1h-10zM5%2016h1v1h-1zM18%2016h1v1h-1zM3%2024h1v1h-1zM20%2024h1v1h-1z%22/%3E%3Cpath%20fill=%22%23d99a6c%22%20d=%22M7%2014h1v1h-1zM11%2014h2v1h-2zM16%2014h1v1h-1zM6%2015h2v1h-2zM9%2015h6v1h-6zM16%2015h2v1h-2zM6%2016h2v1h-2zM9%2016h2v1h-2zM13%2016h2v1h-2zM16%2016h2v1h-2zM7%2017h3v1h-3zM14%2017h3v1h-3zM3%2023h1v1h-1zM20%2023h1v1h-1z%22/%3E%3Cpath%20fill=%22%237f5234%22%20d=%22M8%2014h3v1h-3zM13%2014h3v1h-3zM7%2018h3v1h-3zM14%2018h3v1h-3zM7%2019h10v1h-10zM7%2020h3v1h-3zM11%2020h2v1h-2zM14%2020h3v1h-3zM8%2021h2v1h-2zM11%2021h2v1h-2zM14%2021h2v1h-2zM8%2022h1v1h-1zM10%2022h4v1h-4zM15%2022h1v1h-1zM9%2023h1v1h-1zM11%2023h2v1h-2zM14%2023h1v1h-1zM9%2024h6v1h-6zM10%2025h1v1h-1zM13%2025h1v1h-1zM11%2026h2v1h-2z%22/%3E%3Cpath%20fill=%22%231b1626%22%20d=%22M8%2015h1v1h-1zM15%2015h1v1h-1zM8%2016h1v1h-1zM15%2016h1v1h-1z%22/%3E%3Cpath%20fill=%22%23f08c7c%22%20d=%22M11%2016h2v1h-2zM11%2017h2v1h-2z%22/%3E%3Cpath%20fill=%22%23ffb0a0%22%20d=%22M10%2017h1v1h-1z%22/%3E%3Cpath%20fill=%22%23c8645a%22%20d=%22M13%2017h1v1h-1zM10%2018h4v1h-4z%22/%3E%3Cpath%20fill=%22%23a8744e%22%20d=%22M6%2018h1v1h-1zM6%2019h1v1h-1zM6%2020h1v1h-1zM7%2021h1v1h-1zM7%2022h1v1h-1zM8%2023h1v1h-1zM8%2024h1v1h-1zM9%2025h1v1h-1zM10%2026h1v1h-1zM11%2027h1v1h-1z%22/%3E%3Cpath%20fill=%22%23573622%22%20d=%22M17%2018h1v1h-1zM17%2019h1v1h-1zM10%2020h1v1h-1zM13%2020h1v1h-1zM17%2020h1v1h-1zM10%2021h1v1h-1zM13%2021h1v1h-1zM16%2021h1v1h-1zM9%2022h1v1h-1zM14%2022h1v1h-1zM16%2022h1v1h-1zM10%2023h1v1h-1zM13%2023h1v1h-1zM15%2023h1v1h-1zM15%2024h1v1h-1zM11%2025h2v1h-2zM14%2025h1v1h-1zM13%2026h1v1h-1zM12%2027h1v1h-1z%22/%3E%3Cpath%20fill=%22%23e9868f%22%20d=%22M4%2020h1v1h-1zM4%2021h1v1h-1zM4%2022h1v1h-1zM4%2023h1v1h-1zM4%2024h1v1h-1zM4%2026h1v1h-1z%22/%3E%3Cpath%20fill=%22%23994050%22%20d=%22M19%2020h1v1h-1zM19%2021h1v1h-1zM19%2022h1v1h-1zM19%2023h1v1h-1zM19%2024h1v1h-1zM19%2026h1v1h-1zM4%2027h6v1h-6zM14%2027h6v1h-6z%22/%3E%3Cpath%20fill=%22%23cc5a68%22%20d=%22M5%2021h1v1h-1zM18%2021h1v1h-1zM5%2022h1v1h-1zM18%2022h1v1h-1zM5%2023h2v1h-2zM17%2023h2v1h-2zM5%2024h2v1h-2zM17%2024h2v1h-2zM5%2026h4v1h-4zM15%2026h4v1h-4z%22/%3E%3Cpath%20fill=%22%236b3f22%22%20d=%22M4%2025h4v1h-4zM16%2025h4v1h-4z%22/%3E%3Cpath%20fill=%22%236a4126%22%20d=%22M6%2028h5v1h-5zM13%2028h5v1h-5zM6%2029h5v1h-5zM13%2029h5v1h-5z%22/%3E%3Cpath%20fill=%22%2346271a%22%20d=%22M6%2030h5v1h-5zM13%2030h5v1h-5z%22/%3E%3C/svg%3E","externalUrl":"https://gno.land/r/jeronimoalbi/settlers/nft:token/1","attributes":[{"traitType":"Skin","value":"Medium"},{"traitType":"Hat color","value":"Green"},{"traitType":"Hat","value":"Bent tip (left)"},{"traitType":"Beard color","value":"Brown"},{"traitType":"Beard","value":"Long"},{"traitType":"Tunic","value":"Rose"},{"traitType":"Glasses","value":"None"},{"traitType":"Background","value":"Mint"}]} undefined
// Token metadata of an unknown token: invalid token id
