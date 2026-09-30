import { readFile } from "node:fs/promises";

export const PRODUCTION_OPENRPC_URL = "https://developers.hive.io/openrpc.json";
export const STAGING_OPENRPC_URL = "http://developers-staging.hive.io/openrpc.json";

const MAX_DOCUMENT_CHARS = 20_000_000;

export function parseOpenRpc(text, sourceLabel) {
  let document;
  try {
    document = JSON.parse(String(text).replace(/^\uFEFF/, ""));
  } catch (error) {
    throw new Error(`OpenRPC document from ${sourceLabel} is not JSON: ${error.message}`);
  }
  if (!document || typeof document !== "object" || !Array.isArray(document.methods)) {
    throw new Error(`OpenRPC document from ${sourceLabel} has no methods array`);
  }
  return document;
}

export async function loadOpenRpcDocument({
  filePath,
  urls,
  fetchImpl = globalThis.fetch,
  readFileImpl = readFile,
} = {}) {
  if (filePath) {
    const text = await readFileImpl(filePath, "utf8");
    const document = parseOpenRpc(text, filePath);
    return { document, source: filePath };
  }

  const candidates = (urls && urls.length ? urls : [PRODUCTION_OPENRPC_URL, STAGING_OPENRPC_URL]).filter(Boolean);
  const errors = [];
  for (const url of candidates) {
    try {
      const response = await fetchImpl(url, {
        redirect: "manual",
        headers: { accept: "application/json" },
        signal: AbortSignal.timeout(20_000),
      });
      if (response.status >= 300 && response.status < 400) {
        throw new Error(`redirect ${response.status}`);
      }
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const text = await response.text();
      if (text.length > MAX_DOCUMENT_CHARS) throw new Error("document exceeds size limit");
      const document = parseOpenRpc(text, url);
      return { document, source: url };
    } catch (error) {
      errors.push(`${url}: ${error.message}`);
    }
  }
  throw new Error(`Could not load OpenRPC (${errors.join("; ")})`);
}

export function createCatalog(document, source) {
  const methods = new Map();
  for (const method of document.methods) {
    if (!method || typeof method.name !== "string") continue;
    methods.set(method.name, method);
  }
  const apis = new Map();
  for (const name of methods.keys()) {
    const api = name.split(".")[0];
    apis.set(api, (apis.get(api) || 0) + 1);
  }
  return {
    source: source || document?.info?.title || "openrpc",
    info: document.info || {},
    size: methods.size,
    apis,
    get(name) {
      return methods.get(name) || null;
    },
    names() {
      return [...methods.keys()];
    },
    search({ query = "", api = "", limit = 50 } = {}) {
      const needle = query.trim().toLowerCase();
      const apiNeedle = api.trim().toLowerCase();
      const capped = Math.min(Math.max(Number(limit) || 50, 1), 100);
      const matches = [];
      for (const method of methods.values()) {
        const name = method.name;
        const apiName = String(method["x-hive-api"] || name.split(".")[0]);
        if (apiNeedle && apiName.toLowerCase() !== apiNeedle && !name.toLowerCase().startsWith(`${apiNeedle}.`)) {
          continue;
        }
        const haystack = `${name} ${method.summary || ""} ${method.description || ""}`.toLowerCase();
        if (needle && !haystack.includes(needle)) continue;
        matches.push(summarizeMethod(method));
        if (matches.length >= capped) break;
      }
      return { total: methods.size, returned: matches.length, methods: matches };
    },
    suggest(name, limit = 5) {
      const needle = String(name || "").toLowerCase();
      const suggestions = [];
      for (const candidate of methods.keys()) {
        const lower = candidate.toLowerCase();
        if (lower.includes(needle) || (needle && needle.includes(lower))) suggestions.push(candidate);
        if (suggestions.length >= limit) break;
      }
      return suggestions;
    },
  };
}

export function summarizeMethod(method) {
  return {
    name: method.name,
    api: method["x-hive-api"] || method.name.split(".")[0],
    summary: clip(method.summary || method.description || "", 240),
    paramStructure: method.paramStructure || null,
    deprecated: Boolean(method.deprecated),
  };
}

export function methodSchemaPayload(method) {
  return {
    name: method.name,
    summary: method.summary || "",
    description: clip(method.description || "", 2000),
    paramStructure: method.paramStructure || null,
    deprecated: Boolean(method.deprecated),
    params: method.params || [],
    result: method.result || null,
    examples: Array.isArray(method.examples) ? method.examples.slice(0, 1) : [],
    externalDocs: method.externalDocs || null,
  };
}

function clip(value, max) {
  const text = String(value);
  return text.length > max ? `${text.slice(0, max)}…` : text;
}
