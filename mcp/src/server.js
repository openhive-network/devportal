import { McpServer, ResourceTemplate } from "@modelcontextprotocol/server";
import * as z from "zod";
import { assertAllowedNode, isWriteMethod, normalizeDocUrl, parseNodeAllowlist } from "./policy.js";
import { methodSchemaPayload } from "./catalog.js";
import { buildRpcRequest, htmlToText } from "./rpc.js";

const MAX_RPC_BODY = 256_000;
const MAX_DOC_CHARS = 500_000;
const MAX_TEXT = 20_000;

export function createHiveMcpServer({
  catalog,
  fetchImpl = globalThis.fetch,
  allowBroadcast = false,
  nodeAllowlist,
  defaultNode = "https://api.hive.blog",
  rateLimitPerMinute = 60,
} = {}) {
  if (!catalog) throw new Error("catalog is required");
  const allowlist = nodeAllowlist instanceof Set ? nodeAllowlist : parseNodeAllowlist(nodeAllowlist || []);
  const takeToken = createRateLimiter(rateLimitPerMinute);
  const server = new McpServer({ name: "hive-devportal", version: "0.1.0" });

  server.registerTool(
    "list_methods",
    {
      title: "List Hive JSON-RPC methods",
      description:
        "Search the Hive OpenRPC catalog shipped by developers.hive.io. Returns names and one-line summaries. This does not call a Hive node.",
      inputSchema: z.object({
        query: z.string().optional().describe("Substring matched against method name, summary, and description"),
        api: z.string().optional().describe("API namespace such as database_api or condenser_api"),
        limit: z.number().int().min(1).max(100).optional().describe("Max matches to return (default 50)"),
      }),
      annotations: { readOnlyHint: true, destructiveHint: false, openWorldHint: false },
    },
    async ({ query, api, limit }) => textResult(JSON.stringify(catalog.search({ query, api, limit }), null, 2)),
  );

  server.registerTool(
    "get_method_schema",
    {
      title: "Get Hive method schema",
      description:
        "Return the OpenRPC descriptor for one Hive method: paramStructure (by-name or by-position), params, result schema, and one example. Shapes are inferred from devportal examples, not a full chain type system.",
      inputSchema: z.object({
        method: z.string().min(1).describe("Method name, e.g. condenser_api.get_dynamic_global_properties"),
      }),
      annotations: { readOnlyHint: true, destructiveHint: false, openWorldHint: false },
    },
    async ({ method }) => {
      const found = catalog.get(method);
      if (!found) {
        const suggestions = catalog.suggest(method);
        return textResult(
          `Unknown method ${method}.` + (suggestions.length ? ` Did you mean: ${suggestions.join(", ")}` : ""),
          true,
        );
      }
      return textResult(JSON.stringify(methodSchemaPayload(found), null, 2));
    },
  );

  server.registerTool(
    "hive_rpc_call",
    {
      title: "Call a read-only Hive JSON-RPC method",
      description: allowBroadcast
        ? "POST a JSON-RPC request to an allowlisted Hive HTTPS node. Broadcast opt-in is ON for this process. The server still does not accept or store private keys; sign outside this process."
        : "POST a JSON-RPC request to an allowlisted Hive HTTPS node. Broadcast, network_broadcast_api, and debug_node_api methods are denied. This server never accepts private keys.",
      inputSchema: z.object({
        method: z.string().min(1).describe("OpenRPC method name"),
        params: z
          .union([z.array(z.any()), z.record(z.string(), z.any())])
          .optional()
          .describe("Positional JSON array or named JSON object, matching paramStructure"),
        node: z.string().optional().describe("Allowlisted https origin. Defaults to https://api.hive.blog"),
      }),
      annotations: {
        readOnlyHint: !allowBroadcast,
        destructiveHint: allowBroadcast,
        openWorldHint: true,
      },
    },
    async ({ method, params, node }) =>
      callRpc({ catalog, fetchImpl, allowBroadcast, allowlist, defaultNode, takeToken, method, params, node }),
  );

  server.registerTool(
    "fetch_doc_page",
    {
      title: "Fetch a Hive developer doc page",
      description:
        "Fetch a developers.hive.io (or developers-staging.hive.io) page and return plain text. Use this instead of scraping arbitrary hosts. HTML is tag-stripped and truncated.",
      inputSchema: z.object({
        path: z
          .string()
          .min(1)
          .describe("Site path such as /quickstart/building_agents.html or a full URL on the allowlisted hosts"),
      }),
      annotations: { readOnlyHint: true, destructiveHint: false, openWorldHint: true },
    },
    async ({ path }) => fetchDoc({ fetchImpl, takeToken, path }),
  );

  server.registerResource(
    "openrpc-summary",
    "hive://schema/openrpc",
    {
      title: "Hive OpenRPC catalog summary",
      description: "Source URL and API namespaces for the loaded OpenRPC document. Use get_method_schema for one method.",
      mimeType: "application/json",
    },
    async (uri) => ({
      contents: [
        {
          uri: uri.href,
          mimeType: "application/json",
          text: JSON.stringify(
            {
              source: catalog.source,
              title: catalog.info.title || null,
              methods: catalog.size,
              apis: Object.fromEntries(catalog.apis),
              readOnlyDefault: !allowBroadcast,
            },
            null,
            2,
          ),
        },
      ],
    }),
  );

  server.registerResource(
    "method-schema",
    new ResourceTemplate("hive://method/{name}", { list: undefined }),
    {
      title: "Hive method descriptor",
      description: "OpenRPC descriptor for one method. {name} is the dotted method name.",
      mimeType: "application/json",
    },
    async (uri, variables) => {
      const name = decodeURIComponent(String(variables?.name || ""));
      const found = catalog.get(name);
      if (!found) throw new Error(`Unknown method ${name}`);
      return {
        contents: [
          {
            uri: uri.href,
            mimeType: "application/json",
            text: JSON.stringify(methodSchemaPayload(found), null, 2),
          },
        ],
      };
    },
  );

  return server;
}

async function callRpc({ catalog, fetchImpl, allowBroadcast, allowlist, defaultNode, takeToken, method, params, node }) {
  const found = catalog.get(method);
  if (!found) {
    const suggestions = catalog.suggest(method);
    return textResult(
      `Unknown method ${method}. Calls are limited to the OpenRPC catalog.` +
        (suggestions.length ? ` Did you mean: ${suggestions.join(", ")}` : ""),
      true,
    );
  }
  if (!allowBroadcast && isWriteMethod(method)) {
    return textResult(
      `${method} is denied by default (broadcast / debug). Sign and broadcast outside this MCP process (Beekeeper or Keychain). Set HIVE_MCP_ALLOW_BROADCAST=1 only on a host you control; this server still never accepts private keys.`,
      true,
    );
  }
  if (!takeToken()) return textResult("Rate limit exceeded for this MCP process. Wait and retry.", true);

  let endpoint;
  try {
    endpoint = assertAllowedNode(node || defaultNode, allowlist);
  } catch (error) {
    return textResult(error.message, true);
  }

  let body;
  try {
    body = JSON.stringify(buildRpcRequest(found, params));
  } catch (error) {
    return textResult(error.message, true);
  }
  if (body.length > MAX_RPC_BODY) return textResult("Request body exceeds 256KB", true);

  try {
    const response = await fetchImpl(`${endpoint}/`, {
      method: "POST",
      redirect: "manual",
      headers: { "content-type": "application/json", accept: "application/json" },
      body,
      signal: AbortSignal.timeout(20_000),
    });
    if (response.status >= 300 && response.status < 400) {
      return textResult(`Node ${endpoint} returned a redirect, which is refused`, true);
    }
    const text = await readBounded(response, MAX_DOC_CHARS);
    let payload;
    try {
      payload = JSON.parse(text);
    } catch {
      return textResult(`Node ${endpoint} returned non-JSON (HTTP ${response.status})`, true);
    }
    if (!response.ok || payload.error) {
      return textResult(JSON.stringify({ httpStatus: response.status, error: payload.error || payload }, null, 2), true);
    }
    return textResult(clip(JSON.stringify(payload.result, null, 2), MAX_TEXT));
  } catch (error) {
    return textResult(`Hive node request failed: ${error.message}`, true);
  }
}

async function fetchDoc({ fetchImpl, takeToken, path }) {
  let url;
  try {
    url = normalizeDocUrl(path);
  } catch (error) {
    return textResult(error.message, true);
  }
  if (!takeToken()) return textResult("Rate limit exceeded for this MCP process. Wait and retry.", true);
  try {
    const response = await fetchImpl(url, {
      redirect: "manual",
      headers: { accept: "text/html, text/plain, application/json" },
      signal: AbortSignal.timeout(20_000),
    });
    if (response.status >= 300 && response.status < 400) {
      return textResult(`Refusing redirect from ${url.href}`, true);
    }
    if (!response.ok) return textResult(`Doc fetch HTTP ${response.status} for ${url.href}`, true);
    const type = String(response.headers?.get?.("content-type") || "");
    if (type && !/text\/|application\/json|application\/xhtml/.test(type)) {
      return textResult(`Unsupported content type ${type}`, true);
    }
    const raw = await readBounded(response, MAX_DOC_CHARS);
    const text = type.includes("json") ? raw : htmlToText(raw);
    return textResult(clip(text, MAX_TEXT));
  } catch (error) {
    return textResult(`Doc fetch failed: ${error.message}`, true);
  }
}

async function readBounded(response, maxChars) {
  const text = await response.text();
  if (text.length > maxChars) throw new Error("response exceeds size limit");
  return text;
}

function textResult(text, isError = false) {
  const result = { content: [{ type: "text", text }] };
  if (isError) result.isError = true;
  return result;
}

function clip(text, max) {
  const value = text == null ? "" : String(text);
  return value.length > max ? `${value.slice(0, max)}\n…[truncated]` : value;
}

function createRateLimiter(limit) {
  const windowMs = 60_000;
  const stamps = [];
  return () => {
    const now = Date.now();
    while (stamps.length && now - stamps[0] >= windowMs) stamps.shift();
    if (stamps.length >= limit) return false;
    stamps.push(now);
    return true;
  };
}
