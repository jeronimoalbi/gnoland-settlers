// lib.js - the small tools of the page that do not touch the screen, the network or the wallet.
//
// In plain words: this file knows how to (1) build the "Merkle tree" of the address list and compute the
// proof that one address is in it, (2) find an address in the list, (3) check that a text looks like an
// address, (4) turn the answers of the chain into values, and (5) turn error messages into friendly ones.
//
// The tree here is the same as the one of tools/snapshot/generate.py (Python) and of the realm (Gno), which
// follow the "simple Merkle tree" of Tendermint:
//   - the fingerprint of an address is SHA-256 of the byte 0x00 followed by the address as text;
//   - the fingerprint of a pair is SHA-256 of the byte 0x01 followed by the two fingerprints.
//
// The tests in lib.test.mjs check that this file and generate.py produce the same roots and proofs.

/** Turns bytes into text made of hexadecimal characters (0-9, a-f), two characters per byte. */
export function toHex(bytes) {
  return Array.from(bytes, (b) => b.toString(16).padStart(2, "0")).join("");
}

/**
 * Computes the SHA-256 fingerprint of many byte lists at once.
 *
 * It uses the SHA-256 that the browser has built in (WebCrypto), so no cryptography is written by hand here.
 * The list is processed in small groups so that the page can show its progress and stays responsive.
 *
 * @param {Uint8Array[]} inputs the things to fingerprint
 * @param {(done: number) => void} [onProgress] called after each group with how many are done
 * @returns {Promise<Uint8Array[]>} the fingerprints, in the same order
 */
async function sha256Many(inputs, onProgress) {
  const group = 5000;
  const out = [];
  for (let start = 0; start < inputs.length; start += group) {
    const slice = inputs.slice(start, start + group);
    const hashes = await Promise.all(slice.map((data) => crypto.subtle.digest("SHA-256", data)));
    for (const hash of hashes) out.push(new Uint8Array(hash));
    if (onProgress) onProgress(out.length);
  }
  return out;
}

/** Joins byte lists one after the other into a new one. */
function concat(...parts) {
  const out = new Uint8Array(parts.reduce((sum, part) => sum + part.length, 0));
  let offset = 0;
  for (const part of parts) {
    out.set(part, offset);
    offset += part.length;
  }
  return out;
}

/**
 * Builds the Merkle tree of a list of addresses.
 *
 * The result is the list of "levels": level 0 has the fingerprint of every address, level 1 the fingerprints
 * of the pairs of level 0, and so on up to the last level, that has only the root. When a level has an odd
 * number of items, the last one is carried up to the next level without change (this is what the Tendermint
 * tree does, and it is the same as its rule of splitting at the largest power of two).
 *
 * @param {string[]} addresses the addresses, already sorted (the order is part of the root)
 * @param {(done: number, total: number) => void} [onProgress] called while working
 * @returns {Promise<Uint8Array[][]>} the levels of the tree, from the addresses up to the root
 */
export async function buildTree(addresses, onProgress) {
  if (addresses.length === 0) throw new Error("the list of addresses is empty");

  // N addresses need N hashes for the leaves and N-1 for the pairs above them. Only used for the progress.
  const total = addresses.length * 2 - 1;
  let finished = 0;
  const report = (done) => onProgress && onProgress(finished + done, total);

  const encoder = new TextEncoder();
  const leaves = addresses.map((address) => concat(new Uint8Array([0x00]), encoder.encode(address)));
  let level = await sha256Many(leaves, report);
  finished += level.length;

  const levels = [level];
  while (level.length > 1) {
    const pairs = [];
    for (let i = 0; i + 1 < level.length; i += 2) {
      pairs.push(concat(new Uint8Array([0x01]), level[i], level[i + 1]));
    }
    const next = await sha256Many(pairs, report);
    finished += next.length;
    if (level.length % 2 === 1) next.push(level[level.length - 1]); // the odd one is carried up
    levels.push(next);
    level = next;
  }
  return levels;
}

/** The root of a tree built by buildTree, in hexadecimal. This is the value that the realm stores. */
export function rootOf(levels) {
  return toHex(levels[levels.length - 1][0]);
}

/**
 * The proof that the address at `index` of the list is in the tree, in the format that the realm reads:
 * the position of the address, a dot, and the sibling fingerprints from the bottom to the top, in hex.
 * For example "18846.612278c1...". The proof is safe to show to anyone: the realm only accepts it from the
 * account that it is for.
 *
 * @param {Uint8Array[][]} levels the tree
 * @param {number} index the position of the address in the sorted list
 * @returns {string}
 */
export function proofFor(levels, index) {
  let aunts = "";
  let position = index;
  for (let depth = 0; depth < levels.length - 1; depth++) {
    const sibling = levels[depth][position ^ 1]; // the item next to us in the pair (flip the last bit)
    if (sibling) aunts += toHex(sibling); // no sibling: we were the odd one and nothing is needed
    position = position >> 1;
  }
  return index + "." + aunts;
}

/**
 * Finds an address in the sorted list, with a binary search (halving the range each time, so 360,000
 * addresses need about 19 steps). Addresses are only letters and digits, so the order of JavaScript text
 * is the same as the order that generate.py uses.
 *
 * @returns {number} the position of the address, or -1 if it is not in the list
 */
export function findIndex(addresses, address) {
  let low = 0;
  let high = addresses.length - 1;
  while (low <= high) {
    const middle = (low + high) >> 1;
    if (addresses[middle] === address) return middle;
    if (addresses[middle] < address) low = middle + 1;
    else high = middle - 1;
  }
  return -1;
}

/**
 * Says if a text looks like a Gno.land address: "g1" and 38 more characters from the alphabet of the
 * address format (Bech32), which has no "1", "b", "i" or "o". This does not prove that the account exists.
 * It is checked before an address is used anywhere, so nothing else can be slipped into a request.
 */
export function isAddress(text) {
  return /^g1[023456789acdefghjklmnpqrstuvwxyz]{38}$/.test(text);
}

/**
 * Reads the answer of the chain to a call to a function of a realm ("vm/qeval"). The chain answers with
 * the value and its type in brackets, like `("abc" string)`, `(12 int)` or `(12 int64)`. A GRC721 token ID is
 * a text with its own type, named after the GRC721 package that the realm imports, like
 * `("12" gno.land/p/nt/grc721/v0.TokenID)`. Only a type of a package (`gno.land/p/...`) is accepted.
 *
 * @returns {string|number} the text or the number
 */
export function parseEval(answer) {
  const match = /^\((.*) (string|int|int64|gno\.land\/p\/[a-z0-9_.\/-]+\.TokenID)\)$/s.exec(answer.trim());
  if (!match) throw new Error("unexpected answer from the chain: " + answer);
  return match[2] === "int" || match[2] === "int64" ? Number(match[1]) : JSON.parse(match[1]);
}

/**
 * The command that mints with the gnokey program. The proof is on one line and without spaces, because a
 * space inside a proof makes the realm refuse it.
 */
export function gnokeyCommand(config, proof) {
  return [
    "gnokey maketx call \\",
    `  -pkgpath ${config.realm} -func Mint -args '${proof}' \\`,
    `  -gas-fee ${config.gnokey.gasFee} -gas-wanted ${config.gnokey.gasWanted} -broadcast \\`,
    `  -chainid ${config.chainId} -remote ${config.rpc}:443 <your key name>`,
  ].join("\n");
}

/** The path of the realm on the website, like "/r/jeronimoalbi/settlers/nft". */
export function realmPath(config) {
  return config.realm.slice(config.realm.indexOf("/"));
}

/**
 * The URL of the realm's own Mint page on Gno.land, with the proof already filled in as an argument, ready
 * to send from there with whatever wallet you use.
 */
export function mintURL(config, proof) {
  return `${config.gnoweb}${realmPath(config)}$help&func=Mint&proof=${encodeURIComponent(proof)}`;
}
