import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import { Client } from "@modelcontextprotocol/client";
import { InMemoryTransport } from "@modelcontextprotocol/server";
import { createCatalog, loadOpenRpcDocument, parseOpenRpc } from "../src/catalog.js";
import { isKeyBearingDebugMethod, isWriteMethod, normalizeDocUrl, normalizeNodeUrl } from "../src/policy.js";
import { buildRpcRequest } from "../src/rpc.js";
import { createHiveMcpServer } from "../src/server.js";

const fixtureUrl = new URL("./fixtures/openrpc.json", import.meta.url);
const fixture = parseOpenRpc(await readFile(fixtureUrl, "utf8"), fixtureUrl.pathname);
const catalog = createCatalog(fixture, "fixture");

test("write methods are denied by name", () => {
  assert.equal(isWriteMethod("network_broadcast_api.broadcast_transaction"), true);
  assert.equal(isWriteMethod("condenser_api.broadcast_transaction"), true);
  assert.equal(isWriteMethod("condenser_api.broadcast_transaction_synchronous"), true);
  assert.equal(isWriteMethod("debug_node_api.debug_push_blocks"), true);
  assert.equal(isWriteMethod("debug_node_api.debug_generate_blocks"), true);
  assert.equal(isWriteMethod("debug_node_api.debug_generate_blocks_until"), true);
  assert.equal(isWriteMethod("wallet_bridge_api.broadcast_transaction"), true);
  assert.equal(isWriteMethod("chain_api.push_transaction"), true);
  assert.equal(isWriteMethod("network_node_api.add_node"), true);
  assert.equal(isWriteMethod("network_node_api.set_allowed_peers"), true);
  assert.equal(isWriteMethod("witness_api.enable_fast_confirm"), true);
  assert.equal(isWriteMethod("witness_api.disable_fast_confirm"), true);
  assert.equal(isWriteMethod("condenser_api.get_dynamic_global_properties"), false);
  assert.equal(isWriteMethod("database_api.get_potential_signatures"), false);
  assert.equal(isWriteMethod("network_node_api.get_info"), false);
  assert.equal(isKeyBearingDebugMethod("debug_node_api.debug_generate_blocks"), true);
  assert.equal(isKeyBearingDebugMethod("debug_node_api.debug_generate_blocks_until"), true);
  assert.equal(isKeyBearingDebugMethod("debug_node_api.debug_push_blocks"), false);
});

test("node and doc URLs are pinned to allowlists", () => {
  assert.equal(normalizeNodeUrl("https://api.hive.blog/"), "https://api.hive.blog");
  assert.throws(() => normalizeNodeUrl("http://api.hive.blog"), /https/);
  assert.throws(() => normalizeNodeUrl("https://api.hive.blog/rpc"), /subpath/);
  assert.throws(() => normalizeNodeUrl("https://127.0.0.1"), /IP/);
  assert.equal(
    normalizeDocUrl("/quickstart/building_agents.html").href,
    "https://developers.hive.io/quickstart/building_agents.html",
  );
  assert.equal(
    normalizeDocUrl("http://developers-staging.hive.io/llms.txt").href,
    "http://developers-staging.hive.io/llms.txt",
  );
  assert.throws(() => normalizeDocUrl("http://developers.hive.io/llms.txt"), /https/);
  assert.throws(() => normalizeDocUrl("https://evil.example/openrpc.json"), /not allowlisted/);
  assert.throws(() => normalizeDocUrl("/../../etc/passwd"), /not contain/);
});

test("positional and named JSON-RPC bodies match OpenRPC paramStructure", () => {
  assert.deepEqual(
    buildRpcRequest(catalog.get("condenser_api.get_dynamic_global_properties"), undefined).params,
    [],
  );
  assert.deepEqual(
    buildRpcRequest(catalog.get("database_api.find_accounts"), { accounts: ["hiveio"] }).params,
    { accounts: ["hiveio"] },
  );
  assert.throws(
    () => buildRpcRequest(catalog.get("database_api.find_accounts"), ["hiveio"]),
    /named params/,
  );
});

test("OpenRPC loader falls back when production is not published yet", async () => {
  const seen = [];
  const fetchImpl = async (url) => {
    seen.push(url);
    if (String(url).includes("developers.hive.io")) {
      return { ok: false, status: 404, text: async () => "missing" };
    }
    return { ok: true, status: 200, text: async () => JSON.stringify(fixture) };
  };
  const loaded = await loadOpenRpcDocument({
    urls: ["https://developers.hive.io/openrpc.json", "http://developers-staging.hive.io/openrpc.json"],
    fetchImpl,
  });
  assert.deepEqual(seen, [
    "https://developers.hive.io/openrpc.json",
    "http://developers-staging.hive.io/openrpc.json",
  ]);
  assert.equal(loaded.document.methods.length, fixture.methods.length);
});

test("tools map the OpenRPC catalog and refuse broadcast by default", async () => {
  const calls = [];
  const fetchImpl = async (url, options = {}) => {
    calls.push({ url: String(url), options });
    const target = String(url);
    if (target.includes("building_agents")) {
      return response(200, "<html><style>x{}</style><h1>Building agents</h1><script>secret()</script><p>Use posting keys.</p></html>", "text/html");
    }
    if (options.method === "POST") {
      return response(200, JSON.stringify({ jsonrpc: "2.0", result: { head_block_number: 1 }, id: 1 }), "application/json");
    }
    return response(500, "nope", "text/plain");
  };

  const client = await connect(createHiveMcpServer({ catalog, fetchImpl, rateLimitPerMinute: 10 }));
  const tools = (await client.listTools()).tools.map((tool) => tool.name).sort();
  assert.deepEqual(tools, ["fetch_doc_page", "get_method_schema", "hive_rpc_call", "list_methods"]);

  const listed = JSON.parse((await client.callTool({ name: "list_methods", arguments: { api: "database_api" } })).content[0].text);
  assert.deepEqual(listed.methods.map((method) => method.name), ["database_api.find_accounts"]);

  const schema = JSON.parse(
    (await client.callTool({
      name: "get_method_schema",
      arguments: { method: "condenser_api.get_dynamic_global_properties" },
    })).content[0].text,
  );
  assert.equal(schema.paramStructure, "by-position");

  const rpc = await client.callTool({
    name: "hive_rpc_call",
    arguments: { method: "condenser_api.get_dynamic_global_properties" },
  });
  assert.equal(rpc.isError, undefined);
  assert.match(rpc.content[0].text, /head_block_number/);
  const posted = calls.find((call) => call.options.method === "POST");
  assert.equal(posted.url, "https://api.hive.blog/");
  assert.deepEqual(JSON.parse(posted.options.body), {
    jsonrpc: "2.0",
    method: "condenser_api.get_dynamic_global_properties",
    params: [],
    id: 1,
  });

  const named = await client.callTool({
    name: "hive_rpc_call",
    arguments: { method: "database_api.find_accounts", params: { accounts: ["hiveio"] } },
  });
  assert.notEqual(named.isError, true);
  const namedBody = JSON.parse(calls.filter((call) => call.options.method === "POST").at(-1).options.body);
  assert.deepEqual(namedBody.params, { accounts: ["hiveio"] });

  const denied = await client.callTool({
    name: "hive_rpc_call",
    arguments: { method: "network_broadcast_api.broadcast_transaction", params: { trx: { signatures: ["not-a-key"] } } },
  });
  assert.equal(denied.isError, true);
  assert.match(denied.content[0].text, /denied/);
  assert.equal(calls.filter((call) => String(call.options.body || "").includes("broadcast_transaction")).length, 0);

  const offNode = await client.callTool({
    name: "hive_rpc_call",
    arguments: { method: "condenser_api.get_dynamic_global_properties", node: "https://evil.example" },
  });
  assert.equal(offNode.isError, true);
  assert.match(offNode.content[0].text, /allowlist/);

  const page = await client.callTool({
    name: "fetch_doc_page",
    arguments: { path: "/quickstart/building_agents.html" },
  });
  assert.match(page.content[0].text, /Building agents/);
  assert.match(page.content[0].text, /posting keys/);
  assert.doesNotMatch(page.content[0].text, /secret/);

  const evil = await client.callTool({
    name: "fetch_doc_page",
    arguments: { path: "http://169.254.169.254/latest/meta-data" },
  });
  assert.equal(evil.isError, true);
  assert.equal(calls.some((call) => String(call.url).includes("169.254")), false);

  const summary = await client.readResource({ uri: "hive://schema/openrpc" });
  assert.match(summary.contents[0].text, /"methods": 12/);
  const methodResource = await client.readResource({
    uri: "hive://method/database_api.find_accounts",
  });
  assert.match(methodResource.contents[0].text, /by-name/);
  await client.close();
});

test("broadcast opt-in still does not invent a key field", async () => {
  let body = "";
  const fetchImpl = async (_url, options) => {
    body = options.body;
    return response(200, JSON.stringify({ jsonrpc: "2.0", result: { id: "ok" }, id: 1 }), "application/json");
  };
  const client = await connect(createHiveMcpServer({ catalog, fetchImpl, allowBroadcast: true }));
  const result = await client.callTool({
    name: "hive_rpc_call",
    arguments: {
      method: "condenser_api.broadcast_transaction",
      params: [{ signatures: ["already-signed"] }],
    },
  });
  assert.notEqual(result.isError, true);
  const parsed = JSON.parse(body);
  assert.equal(parsed.method, "condenser_api.broadcast_transaction");
  assert.deepEqual(Object.keys(parsed).sort(), ["id", "jsonrpc", "method", "params"]);
  await client.close();
});

test("allowBroadcast still rejects key-bearing debug_generate_blocks methods", async () => {
  const calls = [];
  const fetchImpl = async (url, options = {}) => {
    calls.push({ url: String(url), options });
    return response(200, JSON.stringify({ jsonrpc: "2.0", result: { ok: true }, id: 1 }), "application/json");
  };
  const client = await connect(createHiveMcpServer({ catalog, fetchImpl, allowBroadcast: true }));

  for (const method of [
    "debug_node_api.debug_generate_blocks",
    "debug_node_api.debug_generate_blocks_until",
  ]) {
    const denied = await client.callTool({
      name: "hive_rpc_call",
      arguments: {
        method,
        params:
          method.endsWith("_until")
            ? { debug_key: "REVIEW_DUMMY_DEBUG_KEY", head_block_time: "2016-01-01T00:00:00" }
            : { debug_key: "REVIEW_DUMMY_DEBUG_KEY", count: 1, skip: 0, miss_blocks: 0 },
      },
    });
    assert.equal(denied.isError, true, method);
    assert.match(denied.content[0].text, /denied|debug key|private keys/i, method);
  }

  assert.equal(
    calls.filter((call) => String(call.options.body || "").includes("debug_generate_blocks")).length,
    0,
  );
  await client.close();
});

test("specialized mutating APIs are denied in the default read-only policy", async () => {
  const calls = [];
  const fetchImpl = async (url, options = {}) => {
    calls.push({ url: String(url), options });
    return response(200, JSON.stringify({ jsonrpc: "2.0", result: { ok: true }, id: 1 }), "application/json");
  };
  const client = await connect(createHiveMcpServer({ catalog, fetchImpl, allowBroadcast: false }));

  const mutating = [
    ["chain_api.push_transaction", { trx: { signatures: ["already-signed"] } }],
    ["network_node_api.add_node", { endpoint: "1.2.3.4:2001" }],
    ["network_node_api.set_allowed_peers", { allowed_peers: [] }],
    ["witness_api.enable_fast_confirm", {}],
    ["witness_api.disable_fast_confirm", {}],
  ];

  for (const [method, params] of mutating) {
    const denied = await client.callTool({
      name: "hive_rpc_call",
      arguments: { method, params },
    });
    assert.equal(denied.isError, true, method);
    assert.match(denied.content[0].text, /denied/i, method);
  }

  assert.equal(
    calls.filter((call) => call.options.method === "POST").length,
    0,
    "denied mutating calls must never reach fetch",
  );
  await client.close();
});

test("agent onboarding mentions the reference server", async () => {
  const guide = await readFile(new URL("../../_i18n/en/quickstart/building_agents.md", import.meta.url), "utf8");
  const llms = await readFile(new URL("../../llms.txt", import.meta.url), "utf8");
  for (const text of [guide, llms]) {
    assert.match(text, /hive_rpc_call/);
    assert.match(text, /HIVE_MCP_ALLOW_BROADCAST/);
  }
  for (const locale of ["es", "de", "fr", "hi", "ru", "zh"]) {
    const localized = await readFile(new URL(`../../_i18n/${locale}/quickstart/building_agents.md`, import.meta.url), "utf8");
    assert.match(localized, /hive_rpc_call/, locale);
  }
});

async function connect(server) {
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const client = new Client({ name: "test", version: "0" });
  await server.connect(serverTransport);
  await client.connect(clientTransport);
  return client;
}

function response(status, text, contentType) {
  return {
    ok: status >= 200 && status < 300,
    status,
    headers: { get: (name) => (name.toLowerCase() === "content-type" ? contentType : null) },
    text: async () => text,
  };
}
