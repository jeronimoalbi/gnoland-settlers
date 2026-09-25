// Tests of lib.js. Run them with `node --test` in this folder (Node.js 20 or newer, and python3).
//
// The tree and the proofs are compared with the ones of tools/snapshot/generate.py, which is the reference:
// if the page and the script ever disagree, the page would build proofs that the realm rejects.

import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

import {
  buildTree,
  findIndex,
  gnokeyCommand,
  isAddress,
  mintURL,
  parseEval,
  proofFor,
  realmPath,
  rootOf,
  toHex,
} from "./lib.js";

const generate = fileURLToPath(new URL("../tools/snapshot/generate.py", import.meta.url));
const fixture = fileURLToPath(new URL("../tools/snapshot/testdata/genesis.json", import.meta.url));

// The addresses of the fixture genesis, sorted, as the list of a snapshot is.
const addresses = JSON.parse(readFileSync(fixture, "utf8"))
  .app_state.balances.map((row) => row.split("=")[0])
  .sort();

/** Asks generate.py for the root and the proof of every address of a list of the given addresses. */
function referenceOf(list) {
  const dir = mkdtempSync(join(tmpdir(), "settlers-"));
  const genesis = join(dir, "genesis.json");
  const balances = list.map((address) => `${address}=20000000ugnot`);
  writeFileSync(genesis, JSON.stringify({ chain_id: "test", genesis_time: "", app_state: { balances } }));

  return list.map((address) => {
    const output = execFileSync("python3", [generate, genesis, "--address", address], { encoding: "utf8" });
    const field = (name) => new RegExp(`^${name}:\\s+(\\S+)`, "m").exec(output)[1];
    return { root: field("root"), proof: field("proof") };
  });
}

test("BuildTreeMatchesGenerateScript", async () => {
  for (const size of [1, 2, 3, 5, 8]) {
    // Arrange
    const list = addresses.slice(0, size);
    const reference = referenceOf(list);

    // Act
    const tree = await buildTree(list);

    // Assert
    list.forEach((address, index) => {
      assert.equal(rootOf(tree), reference[index].root, `root with ${size} addresses`);
      assert.equal(proofFor(tree, index), reference[index].proof, `proof of ${address} with ${size} addresses`);
    });
  }
});

test("BuildTreeRejectsAnEmptyList", async () => {
  // Act
  const build = buildTree([]);

  // Assert
  await assert.rejects(build, /empty/);
});

test("BuildTreeReportsProgressUntilTheEnd", async () => {
  // Arrange
  const calls = [];

  // Act
  await buildTree(addresses, (done, total) => calls.push([done, total]));

  // Assert
  const [done, total] = calls[calls.length - 1];
  assert.equal(done, total);
});

test("ProofOfASingleAddressHasNoAunts", async () => {
  // Arrange
  const tree = await buildTree(addresses.slice(0, 1));

  // Act
  const proof = proofFor(tree, 0);

  // Assert
  assert.equal(proof, "0.");
});

test("FindIndex", () => {
  const cases = [
    { name: "first", address: "b", want: 0 },
    { name: "middle", address: "d", want: 1 },
    { name: "last", address: "f", want: 2 },
    { name: "before the first", address: "a", want: -1 },
    { name: "between two", address: "e", want: -1 },
    { name: "after the last", address: "z", want: -1 },
  ];

  for (const { name, address, want } of cases) {
    // Arrange
    const list = ["b", "d", "f"];

    // Act
    const got = findIndex(list, address);

    // Assert
    assert.equal(got, want, name);
  }
});

test("FindIndexInAnEmptyList", () => {
  // Act
  const got = findIndex([], "g1abc");

  // Assert
  assert.equal(got, -1);
});

test("IsAddress", () => {
  const valid = "g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5";
  const cases = [
    { name: "a real address", text: valid, want: true },
    { name: "empty", text: "", want: false },
    { name: "too short", text: valid.slice(0, 39), want: false },
    { name: "too long", text: valid + "q", want: false },
    { name: "uppercase", text: valid.toUpperCase(), want: false },
    { name: "a letter that Bech32 does not use", text: valid.slice(0, 39) + "b", want: false },
    { name: "other prefix", text: "cosmos" + valid.slice(2), want: false },
    { name: "markup", text: '"><script>x</script>' + valid, want: false },
    { name: "a quote to leave the expression", text: valid.slice(0, 38) + '")', want: false },
    { name: "spaces around", text: " " + valid + " ", want: false },
  ];

  for (const { name, text, want } of cases) {
    // Act
    const got = isAddress(text);

    // Assert
    assert.equal(got, want, name);
  }
});

test("ParseEval", () => {
  const cases = [
    { name: "a text", answer: '("abc" string)', want: "abc" },
    { name: "an empty text", answer: '("" string)', want: "" },
    { name: "a text with a quote", answer: '("a\\"b" string)', want: 'a"b' },
    { name: "a number", answer: "(12 int)", want: 12 },
    { name: "zero", answer: "(0 int)", want: 0 },
    { name: "with a line break at the end", answer: "(3000 int)\n", want: 3000 },
    { name: "a 64-bit number", answer: "(12 int64)", want: 12 },
    { name: "a token id", answer: '("12" gno.land/p/nt/grc721/v0.TokenID)', want: "12" },
    { name: "an empty token id", answer: '("" gno.land/p/nt/grc721/v0.TokenID)', want: "" },
    {
      name: "a token id of a grc721 package at another path",
      answer: '("12" gno.land/p/g17khqpukees4237dtn3astzapmp462vjhsz6st4/grc721/v0.TokenID)',
      want: "12",
    },
    {
      name: "an empty token id of a grc721 package at another path",
      answer: '("" gno.land/p/g17khqpukees4237dtn3astzapmp462vjhsz6st4/grc721/v0.TokenID)',
      want: "",
    },
  ];

  for (const { name, answer, want } of cases) {
    // Act
    const got = parseEval(answer);

    // Assert
    assert.equal(got, want, name);
  }
});

test("ParseEvalRejectsOtherAnswers", () => {
  for (const answer of ["", "abc", "(true bool)", "12", '("12" gno.land/r/evil.TokenID)']) {
    // Act
    const parse = () => parseEval(answer);

    // Assert
    assert.throws(parse, /unexpected answer/, JSON.stringify(answer));
  }
});

test("GnokeyCommandKeepsTheProofInOneLine", () => {
  // Arrange
  const config = {
    realm: "gno.land/r/x/nft",
    chainId: "gnoland-1",
    rpc: "https://rpc.gno.land",
    gnokey: { gasFee: "1ugnot", gasWanted: 2 },
  };
  const proof = "7.aabbcc";

  // Act
  const command = gnokeyCommand(config, proof);

  // Assert
  assert.ok(command.includes(`-args '${proof}'`));
  assert.ok(command.includes("-chainid gnoland-1 -remote https://rpc.gno.land:443"));
});

test("RealmPath", () => {
  // Arrange
  const config = { realm: "gno.land/r/jeronimoalbi/settlers/nft" };

  // Act
  const got = realmPath(config);

  // Assert
  assert.equal(got, "/r/jeronimoalbi/settlers/nft");
});

test("MintURLFillsInTheProof", () => {
  // Arrange
  const config = { gnoweb: "https://gno.land", realm: "gno.land/r/jeronimoalbi/settlers/nft" };

  // Act
  const got = mintURL(config, "7.aabbcc");

  // Assert
  assert.equal(got, "https://gno.land/r/jeronimoalbi/settlers/nft$help&func=Mint&proof=7.aabbcc");
});

test("MintURLEncodesCharactersThatWouldBreakTheQueryString", () => {
  // Arrange
  const config = { gnoweb: "https://gno.land", realm: "gno.land/r/jeronimoalbi/settlers/nft" };

  // Act
  const got = mintURL(config, "1.a&b=c");

  // Assert
  assert.ok(got.endsWith("proof=1.a%26b%3Dc"), got);
});

test("ToHex", () => {
  // Act
  const got = toHex(new Uint8Array([0, 1, 15, 16, 255]));

  // Assert
  assert.equal(got, "00010f10ff");
});
