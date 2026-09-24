package avatar

import (
	"chain/runtime"

	"gno.land/p/nt/ownable/v0"
)

// UnsafeSetAdmin makes owner the admin.
func UnsafeSetAdmin(cur realm, owner address) {
	assertIsDevChain()
	Admin = ownable.NewWithAddress(owner)
}

func assertIsDevChain() {
	id := runtime.ChainID()
	if id != "dev" && id != "tendermint_test" {
		panic("unauthorized")
	}
}
