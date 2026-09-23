// config.local.example.js - copy this file to config.local.js to test the page
// against a local gnodev instead of gnoland-1.
//
// You will also still need to add your local RPC to the `connect-src` line of
// the Content-Security-Policy in index.html

export const config = {
  chainId: "dev",
  rpc: "http://127.0.0.1:26657",
  gnoweb: "http://127.0.0.1:8888",

  // A snapshot built from your local genesis
  snapshot: "snapshot.local.json",
};
