// config.js - the settings of the page, in one place.
//
// In plain words: this says which blockchain, which server and which contract (the "realm") this page talks
// to. They are written here and nowhere else, and they are not taken from the address bar of the browser, so
// a link that somebody sends you cannot make this page talk to a different contract.
//
// The values below are always the production ones (`gnoland-1`) and this file is never edited to test
// locally. To use the page against a local chain (`gnodev`), copy config.local.example.js to
// config.local.js and change the values there instead: config.local.js is in .gitignore, so it never reaches
// git or the deployed page, and it only needs to list the fields that are different from the production
// ones below, since it is merged on top of them. You will also still need to add your local RPC to the
// `connect-src` line of the Content-Security-Policy in index.html, which lists the servers the browser lets
// the page talk to (that line is static markup, so it cannot read this file).

const defaults = {
  // The chain the Settlers realm lives on.
  chainId: "gnoland-1",

  // A public node of the chain. The page only asks it questions ("read" calls). It never sends a
  // transaction: minting itself always happens somewhere else, with your wallet of choice.
  rpc: "https://rpc.gno.land",

  // The website that shows realms in a readable form, used for the links of the page.
  gnoweb: "https://gno.land",

  // The realm that keeps the Settlers: it checks the proofs and mints the tokens.
  realm: "gno.land/r/jeronimoalbi/settlers/nft",

  // The realm that draws the picture of a Settler for an address.
  avatarRealm: "gno.land/r/jeronimoalbi/settlers/avatar",

  // The list of eligible addresses, next to this page. It is the file that tools/snapshot/generate.py writes.
  // The page does not trust it: it checks it against the root that is stored in the realm.
  snapshot: "snapshot.json",

  // The minimum amount of GNOT in the genesis to be in the list. Only used in the texts of the page: the
  // real rule is the list itself.
  minGnot: 15,

  // Only for the gnokey command that the page prints.
  gnokey: {
    gasFee: "30000ugnot",
    gasWanted: 30000000,
  },
};

let overrides = {};
try {
  ({ config: overrides } = await import("./config.local.js"));
} catch {
  // No docs/config.local.js next to this file: use the production defaults above.
}

export const config = { ...defaults, ...overrides };
