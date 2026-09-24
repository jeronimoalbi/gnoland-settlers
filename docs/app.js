// app.js - the page itself: it connects the other files to what you see on the screen.
//
// In plain words, this is what happens, in order:
//   1. The page reads the numbers of the collection from the realm (chain.js), and downloads the list of
//      eligible addresses.
//   2. It builds the Merkle tree of the list (lib.js) and compares its root with the root stored in the
//      realm. If they are different it stops: the list would not be the one the realm knows.
//   3. You type an address. The page looks for it in the list, and if it is there it computes its proof.
//   4. You either open the realm's own Mint page on Gno.land, with the proof already filled in, or copy the
//      proof and the `gnokey` command and run it from a terminal. Either way, the page never sends anything
//      itself: sending the transaction always happens somewhere else, with your wallet of choice.
//   5. You check the address again once you minted, to see the Settler that was drawn for it.
//
// This is the only file that changes the screen. Everything that comes from outside (the list, the chain)
// is put on the screen as plain text with `textContent`, never as HTML, so it cannot add elements or
// scripts to the page.

import { avatarSVG, readCollection, tokenOf } from "./chain.js";
import { buildTree, findIndex, gnokeyCommand, isAddress, mintURL, proofFor, realmPath, rootOf } from "./lib.js";

/** Shortcut to find an element of the page by its id. */
const $ = (id) => document.getElementById(id);

/** Writes a text in an element (as text, never as HTML). */
function say(id, text) {
  $(id).textContent = text;
}

/** Writes a status message and marks it neutral, a success, or an error, for its color. */
function setStatus(id, text, kind) {
  const el = $(id);
  el.textContent = text;
  el.classList.remove("neutral", "success", "error");
  el.classList.add(kind);
}

// What the page knows once it is running.
let config; // the settings this page uses (chain, node, realm), given to run()
let collection = null; // the numbers read from the realm
let addresses = []; // the sorted list of eligible addresses
let tree = null; // the Merkle tree of that list
let account = ""; // the address that is being checked
let proof = ""; // the proof of `account`, if it is eligible
let settlerURL = ""; // the in-memory URL of the Settler picture on screen, freed when it is replaced

/** Reads the collection, downloads the list, and checks the list against the root in the realm. */
async function start() {
  say("min-gnot", config.minGnot);
  $("realm-link").href = `${config.gnoweb}${realmPath(config)}`;
  say("realm-link", config.realm);

  try {
    collection = await readCollection(config);
  } catch (error) {
    setStatus("list-status", "Could not read the realm: " + error.message, "error");
    return;
  }
  showCollection();

  if (!collection.root) {
    setStatus("list-status", "The mint is not open yet: the realm does not have the list of accounts.", "neutral");
    return;
  }

  try {
    setStatus("list-status", "Downloading the list of addresses...", "neutral");
    const response = await fetch(config.snapshot);
    if (!response.ok) throw new Error("HTTP " + response.status);
    addresses = (await response.json()).addresses;

    // Building the tree takes a few seconds for a big list, and this shows how far it is.
    tree = await buildTree(addresses, (done, total) => {
      const percent = Math.round((done / total) * 100);
      setStatus("list-status", `Checking the list against the root of the realm: ${percent}%`, "neutral");
    });
  } catch (error) {
    setStatus("list-status", "Could not load the list of addresses: " + error.message, "error");
    return;
  }

  // The important check: the list is only accepted if it is exactly the one the realm knows.
  if (rootOf(tree) !== collection.root || addresses.length !== collection.total) {
    setStatus(
      "list-status",
      "Stopped: the list of addresses does not match the root stored in the realm, so it can not be used.",
      "error",
    );
    return;
  }
  const count = addresses.length.toLocaleString("en");
  setStatus("list-status", `The list is correct: its root is the one stored in the realm (${count} accounts).`, "success");
  $("account-section").hidden = false;
}

/** Shows the numbers of the collection that were read from the realm. */
function showCollection() {
  say("minted", `${collection.minted} of ${collection.cap}`);
  say("total", collection.total.toLocaleString("en"));
  say("root", collection.root || "not set yet");
}

/** Checks one address: if it has a Settler already, if it is in the list, and if it can mint now. */
async function checkAccount(address) {
  account = address;
  proof = "";

  if (!isAddress(address)) {
    setStatus("account-status", "This is not an address. It starts with g1 and has 40 characters.", "error");
    hideMintAndSettler();
    return;
  }

  setStatus("account-status", "Checking...", "neutral");
  let id;
  try {
    id = await tokenOf(config, address);
    collection = await readCollection(config); // the numbers may have changed since the page was opened
    showCollection();
  } catch (error) {
    setStatus("account-status", "Could not read the realm: " + error.message, "error");
    hideMintAndSettler();
    return;
  }

  if (id > 0) {
    setStatus("account-status", `This account already has the Settler number ${id}.`, "success");
    $("mint-section").hidden = true;
    $("settler-section").hidden = false;
    setStatus("settler-status", "", "neutral");
    await showSettler(address, id);
    return;
  }

  const index = findIndex(addresses, address);
  if (index < 0) {
    setStatus(
      "account-status",
      `This account can not mint: it did not have at least ${config.minGnot} GNOT in the genesis of ${config.chainId}.`,
      "neutral",
    );
    hideMintAndSettler();
    return;
  }
  if (collection.minted >= collection.cap) {
    setStatus("account-status", "This account was eligible, but all the Settlers were minted.", "neutral");
    hideMintAndSettler();
    return;
  }

  // The proof is computed from the list, here, in this browser. Nobody else is asked for it.
  proof = proofFor(tree, index);
  setStatus("account-status", "This account can mint one Settler.", "success");
  say("proof", proof);
  say("command", gnokeyCommand(config, proof));
  $("mint-link").href = mintURL(config, proof);
  $("mint-section").hidden = false;
  $("settler-section").hidden = false;
  // Not the id > 0 branch: any Settler shown before belongs to a different address, clear it.
  $("settler").hidden = true;
  $("settler-link").hidden = true;
  setStatus("settler-status", 'Not minted yet. After you mint, press "Check again" to see it here.', "neutral");
}

/** Hides the mint and Settler sections, for an address that is not eligible or could not be read. */
function hideMintAndSettler() {
  $("mint-section").hidden = true;
  $("settler-section").hidden = true;
}

/** Shows the picture of a Settler and a link to its page. */
async function showSettler(address, id) {
  try {
    const svg = await avatarSVG(config, address, 192);
    if (!svg) return;
    // An SVG shown through <img> is only a picture: a browser does not run scripts inside it.
    const url = URL.createObjectURL(new Blob([svg], { type: "image/svg+xml" }));
    if (settlerURL) URL.revokeObjectURL(settlerURL); // free the picture that was shown before
    settlerURL = url;
    $("settler").src = url;
    $("settler").hidden = false;
    $("settler-link").href = `${config.gnoweb}${realmPath(config)}:token/${id}`;
    $("settler-link").hidden = false;
  } catch (error) {
    setStatus("settler-status", "Could not draw the Settler: " + error.message, "error");
  }
}

/** Copies the text of an element to the clipboard and says so on the button for a moment. */
async function copy(id, button) {
  await navigator.clipboard.writeText($(id).textContent);
  const label = button.textContent;
  button.textContent = "Copied";
  setTimeout(() => (button.textContent = label), 1500);
}

/** Wires the page and starts it, using the given settings (chain, node, realm), see config.js. */
export function run(activeConfig) {
  config = activeConfig;

  $("check").addEventListener("click", () => checkAccount($("address").value.trim()));
  $("address").addEventListener("keydown", (event) => {
    if (event.key === "Enter") checkAccount($("address").value.trim());
  });
  $("recheck").addEventListener("click", () => checkAccount(account));
  $("copy-proof").addEventListener("click", (event) => copy("proof", event.target));
  $("copy-command").addEventListener("click", (event) => copy("command", event.target));

  start();
}
