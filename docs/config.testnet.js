// config.testnet.js - the settings of testnet.html, in one place.
//
// Unlike config.local.js (personal, gitignored, for a local gnodev), this file is committed: it is the one
// place to edit to point testnet.html at a different testnet later, chain ID, node, gnoweb and realm paths
// all live here. If the RPC host changes too, also update the `connect-src` line of the
// Content-Security-Policy in testnet.html, that line is static markup and cannot read this file.

export const config = {
  // The testnet the Settlers realm lives on.
  chainId: "pearl-1",

  // A public node of that testnet. 
  rpc: "https://rpc.pearl.testnets.gno.land",

  // The website that shows realms in a readable form on that testnet, used for the links of the page.
  gnoweb: "https://pearl.testnets.gno.land",

  // The realm that keeps the Settlers on that testnet: it checks the proofs and mints the tokens.
  realm: "gno.land/r/g1dxrp4g8zw90lwsu4v2qqlqkpj7234mdvaayrwf/settlers/nft",

  // The realm that draws the picture of a Settler for an address, on that testnet.
  avatarRealm: "gno.land/r/g1dxrp4g8zw90lwsu4v2qqlqkpj7234mdvaayrwf/settlers/avatar",

  // The list of eligible addresses for that testnet, next to this page. The page does not trust it: it
  // checks it against the root that is stored in the realm there.
  snapshot: "snapshot.json",

  // Only used in the texts of the page: the real rule is the list itself.
  minGnot: 15,

  // Only for the gnokey command that the page prints.
  gnokey: {
    gasFee: "30000ugnot",
    gasWanted: 30000000,
  },
};
