# Gnoland Settlers

Soulbound pixel-art gnomes for the early settlers of Gno.land.

## Who can mint one

Any Gno.land account that already held at least 15 GNOT when the `gnoland-1` chain launched can mint one
Settler, one per account, first come first served. The list of eligible accounts (the "snapshot") comes
straight from the public genesis of `gnoland-1`, so nobody has to take anyone's word for it, you can check
it yourself, see `tools/snapshot`.

## A friendly word of caution

This project is made by one person, for fun. It has not been audited by anyone. Everything here is open source,
so please have a look yourself, or ask someone you trust to, before connecting a wallet or signing anything.
Nobody involved in this project is responsible for what happens to your account or your funds; using it is
entirely your own choice and your own responsibility.

## Mint with gnokey

Get your proof (from the mint page below, or with `tools/snapshot/generate.py`) and send it to the realm:

```
gnokey maketx call \
  -pkgpath gno.land/r/jeronimoalbi/settlers/nft -func Mint -args '<PROOF>' \
  -gas-fee 30000ugnot -gas-wanted 30000000 -broadcast \
  -chainid gnoland-1 -remote https://rpc.gno.land:443 <YOUR KEY NAME>
```

Or mint from the browser: [jeronimoalbi.github.io/gnoland-settlers](https://jeronimoalbi.github.io/gnoland-settlers/)

## Try it on a testnet first

If you'd rather try minting without touching the real `gnoland-1` chain, there's a testnet version of the
mint page at [jeronimoalbi.github.io/gnoland-settlers/testnet.html](https://jeronimoalbi.github.io/gnoland-settlers/testnet.html).
It works exactly the same way, just on a chain made for testing.

## Use your Settler's image elsewhere

Once minted, a separate [avatar](r/jeronimoalbi/settlers/avatar) realm can draw your Settler as a picture
(an image or Markdown) on request, for anyone to use. It's meant for other realms and web apps that want to
show a Settler next to an address, a profile picture, a leaderboard row, a forum post, without needing to
know anything about how the art works themselves. See its
[README](r/jeronimoalbi/settlers/avatar/README.md) for the details.
