# Settlers mint page

This is a static page for GitHub Pages where an eligible account mints its Settler.
It has no build step and no dependencies, the browser runs the files of this folder exactly as they are written.

## What it does

1. Reads the collection from the realm through the public node.
2. Downloads `snapshot.json`, builds its Merkle tree in the browser and compares the root with the one in the
   realm. If they differ the page stops: the list is only used if it is the one the realm knows. This is why
   the file can be hosted anywhere without trusting the host.
3. Takes an address that is typed, and looks for it in the list. If it is there, the proof is computed in the
   browser.
4. Offers two ways to mint, side by side: a link to the realm's own Mint page on Gno.land with the proof
   already filled in (sent from there with whatever wallet you use), or the proof and the `gnokey` command
   for the same. Either way, this page never sends anything itself and never sees a key.
5. Once you minted, checking the address again shows the Settler drawn by the avatar realm.

## Files

| File | What it is |
| --- | --- |
| `index.html` | The page, and the Content-Security-Policy (what it may load and contact) |
| `style.css` | The looks, with the colors and fonts of Gno.land, light and dark |
| `config.js` | Chain, node, realm and the gnokey gas values: the production defaults |
| `config.local.example.js` | Copy to `config.local.js` (gitignored) to override values for a local gnodev |
| `config.testnet.js` | Chain, node, realm and gas values for `testnet.html`, the one file to edit for a different testnet |
| `lib.js` | Merkle tree, proofs, address check, chain answers. No screen, network or wallet |
| `chain.js` | Reads from the chain (`vm/qeval`, `vm/qrender`). Never writes |
| `app.js` | The page: connects the others to the screen (text only, never HTML). Exports `run(config)` |
| `main.js` | Starts `index.html` with `config.js` (production, `gnoland-1`) |
| `testnet-main.js` | Starts `testnet.html` with `config.testnet.js` |
| `testnet.html` | The same mint page, pointed at a testnet instead of `gnoland-1` |
| `lib.test.mjs` | Tests of `lib.js` |
| `snapshot.json` | The list of eligible addresses (not in git until publishing, see below) |

## Tests

```
cd docs
node --test
```

Needs Node.js 20 or newer and `python3`. The tree and the proofs are compared with the ones of
`tools/snapshot/generate.py`, which is the reference.

To try the page against a local chain (`gnodev`), copy `config.local.example.js` to `config.local.js` and
adjust it if your gnodev uses different ports than its defaults; `config.local.js` is in `.gitignore`, so it
is picked up automatically by `config.js` and never reaches git or the deployed page, and it can be left in
place between sessions. You still need to add your local RPC to the `connect-src` of the policy in
`index.html`, since that line is static markup and cannot read `config.local.js`. Then put a
`snapshot.local.json` made from the genesis of that chain next to this file (`tools/snapshot/generate.py`),
set the same root in the realm with `SetSnapshot`, and serve the folder with any static server, for example
`python3 -m http.server`.

Measured with the real list (363,791 addresses), building the tree takes about 3 seconds in Chromium and in
Node.js, on the main thread.

## Publish on GitHub Pages

1. Generate the list from the official genesis (see `tools/snapshot/README.md`) and check that the root is the
   one that was set in the realm with `SetSnapshot`:

   ```
   python3 tools/snapshot/generate.py genesis.json
   cp tools/snapshot/out/snapshot.json docs/snapshot.json
   ```

   The file is 15.6 MB (about 9 MB when served compressed), under the limits of GitHub.
2. Commit it, and in the settings of the repository set Pages to serve the branch `main`, folder `/docs`.
3. Check `config.js` (`chainId`, `realm`, `avatarRealm`) and the `connect-src` of the policy in `index.html`.
4. Open the page. With the real realm it must say "The list is correct". Check an eligible address, then try
   both the "Mint on Gno.land" link and the `gnokey` command against `gnoland-1`.
