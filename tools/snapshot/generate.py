#!/usr/bin/env python3
"""Generate a list of Gno.land accounts with Merkle proofs.

Included accounts had at least 15 GNOT at the launch of gnoland-1.

The accounts come from the official genesis.json (app_state.balances, rows like
"<address>=<amount>ugnot[;vesting=...]"). The amount is the total of the account, including the
coins that are still locked by vesting.

The addresses are sorted and put in a Tendermint simple Merkle tree, the one that the Gno stdlib
package crypto/merkle verifies: leaf = SHA256(0x00 || address), node = SHA256(0x01 || left || right).
The proof of an address is "<index>.<hex of the concatenated 32-byte aunts>", from the leaf up.

In plain words: a Merkle tree is a way to take a very long list (here, 300,000+ addresses) and boil it
down to one short "fingerprint" (the root), such that anyone can later prove that one specific address
was part of the list by showing only a handful of extra fingerprints (its "proof"), not the whole list.
That is what makes it possible for the Gno.land realm to check who is eligible without storing the
whole list on-chain, it only stores the one root, and each account brings its own proof when it mints.

Write the `out/snapshot.json` from the official genesis:
  python3 generate.py genesis.json

Print the proof of one address:
  python3 generate.py genesis.json --address g1...
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any

THRESHOLD = 15_000_000  # 15 GNOT in ugnot (ugnot is the smallest unit: 1 GNOT = 1,000,000 ugnot)

# The folder this script lives in, so "out/snapshot.json" is always written next to it,
# no matter which directory the script is run from.
current_dir = Path(__file__).resolve().parent


def amount(row: str) -> tuple[str, int]:
    """Returns (address, ugnot) of a balance row."""

    # A row looks like "g1abc...=15000000ugnot" or "g1abc...=15000000ugnot;lock=..."
    addr, rest = row.split("=", 1)
    return addr, int(rest.split(";")[0].removesuffix("ugnot"))  # fails on any other denom


def eligible(genesis: dict[str, Any]) -> list[str]:
    # Turn every balance row into (address, ugnot), keep only accounts with at least
    # THRESHOLD ugnot, and sort the addresses alphabetically.
    return sorted(a for a, n in map(amount, genesis["app_state"]["balances"]) if n >= THRESHOLD)


def leaf_hash(b: bytes) -> bytes:
    # A "leaf" is one address at the bottom of the tree. The 0x00 byte in front is not part of the
    # address, it just marks "this is a leaf, not a branch", so a leaf hash and a branch hash
    # can never be mixed up even if their raw bytes happened to look similar.
    return hashlib.sha256(b"\x00" + b).digest()


def inner_hash(l: bytes, r: bytes) -> bytes:
    # A "branch" (or "node") combines two hashes into one, moving up the tree. The 0x01 byte plays the
    # same role as 0x00 above, marking "this is a branch". The l and r are already hashes, not addresses.
    return hashlib.sha256(b"\x01" + l + r).digest()


def tree(hashes: list[bytes], aunts: list[list[bytes]]) -> bytes:
    """Returns the root of hashes and appends to aunts[i] the sibling hashes of leaf i, bottom up."""

    # Split the list roughly in half, build the left and right halves separately, then combine
    # their two hashes into one. Recursing down to a single hash and combining back up is what
    # turns a flat list into a tree shape.
    n = len(hashes)
    if n == 1:
        return hashes[0]  # only one hash left, it's both the root of this small piece and a leaf

    k = 1
    while k * 2 < n:  # largest power of two below n
        k *= 2

    # Build the left half (first k hashes) and the right half (the rest) separately
    left = tree(hashes[:k], aunts[:k])
    right = tree(hashes[k:], aunts[k:])

    # Every leaf on the left needs the right branch's hash as part of its proof (and vice versa),
    # because that is the sibling it would need to combine with to reconstruct this level's hash.
    for a in aunts[:k]:
        a.append(right)

    for a in aunts[k:]:
        a.append(left)

    return inner_hash(left, right)


def root_from_proof(leaf: bytes, index: int, total: int, aunts: list[bytes]) -> bytes | None:
    """Rebuilds the root from a leaf hash and its aunts (the reverse of tree)."""

    # This walks the same left/right split that tree() used, but backwards, starting from one leaf
    # and its short list of "aunt" hashes (the siblings collected above), it recombines them step
    # by step until it ends up with what should be the tree's root. If that matches the real root,
    # the leaf (address) was genuinely part of the original list, if not, the proof is invalid.
    if total == 1:
        return leaf if not aunts else None  # a single-item tree has no aunts at all

    k = 1
    while k * 2 < total:
        k *= 2

    if not aunts:
        return None  # ran out of aunts before reaching a single hash, the proof is too short

    if index < k:
        # This leaf was on the left side, so its aunt at this level is the hash of the right side
        left = root_from_proof(leaf, index, k, aunts[:-1])
        return inner_hash(left, aunts[-1]) if left else None

    # This leaf was on the right side, so its aunt at this level is the hash of the left side
    right = root_from_proof(leaf, index - k, total - k, aunts[:-1])
    return inner_hash(aunts[-1], right) if right else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("genesis", help="path to the genesis.json of gnoland-1")
    ap.add_argument("--address", help="print the proof of this address instead of writing the snapshot")
    args = ap.parse_args()

    # Load the genesis file and compute the sorted list of eligible addresses from it
    raw = Path(args.genesis).read_bytes()
    genesis = json.loads(raw)
    addrs = eligible(genesis)

    # Build the whole Merkle tree once
    aunts = [[] for _ in addrs]
    root = tree([leaf_hash(a.encode()) for a in addrs], aunts)

    def check(i: int) -> None:
        # Rebuild the root from address i's own proof and make sure it matches the real
        # root. This is a safety net that runs for every address before anything is printed
        # or saved, so a bug in the tree/proof code would be caught here instead of shipping
        # a broken snapshot.
        assert root_from_proof(leaf_hash(addrs[i].encode()), i, len(addrs), aunts[i]) == root, addrs[i]

    if args.address:
        addr = args.address.strip()
        if addr not in addrs:
            have = next((n for a, n in map(amount, genesis["app_state"]["balances"]) if a == addr), None)
            gnot = f"{have // 1_000_000}.{have % 1_000_000:06d}" if have is not None else ""
            why = "it is not in the genesis" if have is None else f"it has {gnot} GNOT in the genesis"
            sys.exit(f"{addr} is not eligible: at least {THRESHOLD // 1_000_000} GNOT are needed and {why}")

        i = addrs.index(addr)
        check(i)

        print(f"address: {addr}")
        print(f"index:   {i} of {len(addrs)}")
        print(f"root:    {root.hex()}")
        # The proof format expected by the realm. The address's position in the list, a dot,
        # then all of its aunt hashes concatenated and written as one long hexadecimal string.
        print(f"proof:   {i}.{b''.join(aunts[i]).hex()}")
        print("note:    sign the transaction with the key of this address: the token goes to the signer")
        return

    # Default mode, check every single address's proof, then write the full snapshot
    for i in range(len(addrs)):
        check(i)

    snapshot = {
        "chain_id": genesis["chain_id"],
        "genesis_time": genesis["genesis_time"],
        "genesis_sha256": hashlib.sha256(raw).hexdigest(),
        "threshold_ugnot": THRESHOLD,
        "total": len(addrs),
        "root": root.hex(),
        "addresses": addrs,
    }
    data = json.dumps(snapshot, separators=(",", ":")).encode()
    out = current_dir / "out" / "snapshot.json"
    out.parent.mkdir(exist_ok=True)
    out.write_bytes(data)

    print(f"accounts: {len(addrs)}")
    print(f"root: {root.hex()}")
    print(f"snapshot.json: {len(data) / 1e6:.1f} MB")
    print(f"sha256: {hashlib.sha256(data).hexdigest()}")


if __name__ == "__main__":
    main()
