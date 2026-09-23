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
