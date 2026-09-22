# Settlers snapshot

Snapshot is used to get the list of accounts that can mint a Settlers gnome, these accounts must have **at least
15 GNOT in the launch balances of `gnoland-1`**. The amount is the total of the account in the genesis, including
the coins that are still locked by vesting.

The `generate.py` script reads the official `genesis.json` using Python 3 standard library only and writes an
`out/snapshot.json` file with the sorted list of addresses and the Merkle root of the list. The proof that an
address is in the list is computed from the list, so nobody has to trust a website, you can do it yourself.

## Check the list yourself

1. Download the genesis of `gnoland-1` and unpack it:

```
wget https://github.com/gnolang/gno/releases/download/chain/mainnet/genesis.json.gz
gunzip genesis.json.gz
```

2. Check that it is the official one:

```
sha256sum genesis.json
```

This must print `ea22691003130eae3ba975b7d16460706b5d75ce6c04ae82c0c4faeab7de91f0`.

3. Generate the list:

```
python3 generate.py genesis.json
```

It prints the number of accounts, the Merkle root and the sha256 of `out/snapshot.json`.
Compare them with the published ones, and the root with the one stored in the realm.

## Get the proof for your account by hand

```
python3 generate.py genesis.json --address g1youraddress...
```

It prints the position of your address in the list, the root, and your proof:

```
address: g1youraddress...
index:   18846 of 363791
root:    320ba6b6...
proof:   18846.612278c1...
```

If the address is not eligible, it says why (its balance in the genesis, or that it is not in the genesis).

Sign the mint transaction with the key of the same address, the NFT token goes to the signer, and the proof only
works for that address. With another key the transaction aborts.

Then send the proof to the realm `gno.land/r/jeronimoalbi/settlers/nft`. It checks the proof against its root and
mints only to the account that signs the transaction, so a proof is useless for anybody else. The tokens are
numbered in mint order, and an account can mint only one:

```
gnokey maketx call \
  -pkgpath gno.land/r/jeronimoalbi/settlers/nft -func Mint -args '<PROOF>' \
  -gas-fee 30000ugnot -gas-wanted 30000000 -broadcast \
  -chainid gnoland-1 -remote https://rpc.gno.land:443 <YOUR KEY NAME>
```
## Format of `out/snapshot.json`

```
{"chain_id": "gnoland-1", "genesis_time": "...", "genesis_sha256": "...", "threshold_ugnot": 15000000,
 "total": 363791, "root": "...", "addresses": ["g1...", ...]}
```
