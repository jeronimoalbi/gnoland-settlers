// PKGPATH: gno.land/r/jeronimoalbi/settlers/nft/filetests/collection_id_has_the_realm_path_and_the_symbol_filetest

// CollectionID has the path of the realm (derived, not hardcoded, see nft.gno's init) and the symbol.
package collection_id_has_the_realm_path_and_the_symbol_filetest

import "gno.land/r/jeronimoalbi/settlers/nft"

func main() {
	println(nft.CollectionID())
}

// Output:
// gno.land/r/jeronimoalbi/settlers/nft.SETTLER.0000000
