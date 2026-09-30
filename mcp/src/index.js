#!/usr/bin/env node
import { serveStdio } from "@modelcontextprotocol/server/stdio";
import { createCatalog, loadOpenRpcDocument, PRODUCTION_OPENRPC_URL, STAGING_OPENRPC_URL } from "./catalog.js";
import { parseNodeAllowlist } from "./policy.js";
import { createHiveMcpServer } from "./server.js";

const schemaPath = argValue("--schema") || process.env.HIVE_OPENRPC_PATH || "";
const explicitUrl = process.env.HIVE_OPENRPC_URL || "";
const allowBroadcast = envFlag("HIVE_MCP_ALLOW_BROADCAST") || process.argv.includes("--allow-broadcast");
const extraNodes = (process.env.HIVE_MCP_NODES || "")
  .split(",")
  .map((item) => item.trim())
  .filter(Boolean);
const rateLimit = Number(process.env.HIVE_MCP_RATE_LIMIT || 60);
const defaultNode = process.env.HIVE_MCP_DEFAULT_NODE || "https://api.hive.blog";

const { document, source } = await loadOpenRpcDocument({
  filePath: schemaPath || undefined,
  urls: explicitUrl ? [explicitUrl] : [PRODUCTION_OPENRPC_URL, STAGING_OPENRPC_URL],
});
const catalog = createCatalog(document, source);
console.error(
  `hive-devportal-mcp: ${catalog.size} methods from ${source}; broadcast ${allowBroadcast ? "ENABLED" : "denied"}; default node ${defaultNode}`,
);

const handle = serveStdio(() =>
  createHiveMcpServer({
    catalog,
    allowBroadcast,
    nodeAllowlist: parseNodeAllowlist(extraNodes),
    defaultNode,
    rateLimitPerMinute: Number.isFinite(rateLimit) && rateLimit > 0 ? rateLimit : 60,
  }),
);

process.on("SIGINT", () => {
  void handle.close();
});

function envFlag(name) {
  return ["1", "true", "yes", "on"].includes(String(process.env[name] || "").trim().toLowerCase());
}

function argValue(flag) {
  const index = process.argv.indexOf(flag);
  if (index === -1) return "";
  return process.argv[index + 1] || "";
}
