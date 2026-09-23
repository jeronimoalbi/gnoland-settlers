// chain.js - reads information from the blockchain.
//
// In plain words: this file asks a public node of Gno.land questions, for example "how many Settlers were
// minted?" or "does this address have a Settler?". It only reads. It never sends a transaction and it never
// sees any key or password: minting itself always happens somewhere else, with your wallet of choice.
//
// The questions go to the node as "ABCI queries" (JSON over HTTPS):
//   - vm/qeval   runs a function of a realm and gives back its value, like `MerkleRoot()`;
//   - vm/qrender runs the Render function of a realm for a path and gives back its text.
//
// Both are read-only: the node runs them on its current state and does not change anything.

import { config } from "./config.js";
import { isAddress, parseEval } from "./lib.js";

/**
 * Sends one query to the node and returns the answer as text.
 *
 * @param {string} path the kind of query, "vm/qeval" or "vm/qrender"
 * @param {string} data what to ask, for example `gno.land/r/some/realm.MerkleRoot()`
 */
async function query(path, data) {
  const response = await fetch(config.rpc, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "abci_query",
      // The node wants the question in base64.
      params: { path, data: btoa(data) },
    }),
  });
  if (!response.ok) throw new Error("the node answered with an error: HTTP " + response.status);

  const body = await response.json();
  const answer = body.result.response.ResponseBase;
  if (answer.Error) throw new Error("the chain could not answer: " + (answer.Log || answer.Error["@type"]));

  // The answer comes in base64 too, as UTF-8 text (an empty answer has no data at all).
  const bytes = Uint8Array.from(atob(answer.Data || ""), (c) => c.charCodeAt(0));
  return new TextDecoder().decode(bytes);
}

/** Runs an expression of the Settlers realm, like `Cap()`, and returns its value. */
async function evaluate(expression) {
  return parseEval(await query("vm/qeval", config.realm + "." + expression));
}

/**
 * Reads the numbers of the collection from the realm.
 *
 * @returns {Promise<{root: string, total: number, cap: number, minted: number}>}
 *   root: the Merkle root of the list of eligible addresses ("" until the realm is opened),
 *   total: how many addresses the list has, cap: how many Settlers can be minted, minted: how many were.
 */
export async function readCollection() {
  const [root, total, cap, minted] = await Promise.all([
    evaluate("MerkleRoot()"),
    evaluate("Total()"),
    evaluate("Cap()"),
    evaluate("TotalSupply()"),
  ]);
  return { root, total, cap, minted };
}

/**
 * The id of the Settler of an address, or 0 if it has none.
 * The address is checked first: it is put inside the question, so only a real address is allowed in it.
 */
export async function tokenOf(address) {
  if (!isAddress(address)) throw new Error("not an address");
  return evaluate(`TokenOf("${address}")`);
}

/**
 * The picture (SVG) of the Settler of an address, drawn by the avatar realm, as text.
 * The page shows it inside an <img>, where a browser never runs scripts, even if the image had any.
 */
export async function avatarSVG(address, size) {
  if (!isAddress(address)) throw new Error("not an address");
  return query("vm/qrender", `${config.avatarRealm}:svg/${address}?size=${size}`);
}
