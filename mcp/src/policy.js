/** Methods that mutate chain or node state. Denied unless explicitly opted in. */
const WRITE_API_PREFIXES = ["network_broadcast_api.", "debug_node_api."];

const WRITE_METHOD_RE = /(?:^|\.)broadcast_/i;

export const DEFAULT_NODE_ORIGINS = [
  "https://api.hive.blog",
  "https://api.deathwing.me",
  "https://anyx.io",
];

export const DOC_HOSTS = new Set(["developers.hive.io", "developers-staging.hive.io"]);

export function isWriteMethod(name) {
  const method = String(name || "");
  if (WRITE_API_PREFIXES.some((prefix) => method.startsWith(prefix))) return true;
  return WRITE_METHOD_RE.test(method);
}

export function parseNodeAllowlist(extraOrigins = []) {
  const origins = new Set(DEFAULT_NODE_ORIGINS);
  for (const raw of extraOrigins) {
    const value = String(raw || "").trim();
    if (!value) continue;
    origins.add(normalizeNodeUrl(value));
  }
  return origins;
}

export function normalizeNodeUrl(raw) {
  let url;
  try {
    url = new URL(String(raw));
  } catch {
    throw new Error(`Invalid node URL: ${raw}`);
  }
  if (url.protocol !== "https:") {
    throw new Error("Hive API nodes must be https");
  }
  if (url.username || url.password) {
    throw new Error("Node URL must not include credentials");
  }
  if (url.port && url.port !== "443") {
    throw new Error("Only the default HTTPS port is allowed for API nodes");
  }
  if (url.pathname !== "/" && url.pathname !== "") {
    throw new Error("API node URL must be the origin (POST /), not a subpath");
  }
  if (url.search || url.hash) {
    throw new Error("API node URL must not include a query or fragment");
  }
  if (isIpHost(url.hostname)) {
    throw new Error("IP addresses are not allowed as API nodes");
  }
  return `https://${url.hostname.toLowerCase()}`;
}

export function assertAllowedNode(raw, allowlist) {
  const origin = normalizeNodeUrl(raw);
  if (!allowlist.has(origin)) {
    throw new Error(`Node ${origin} is not in the allowlist`);
  }
  return origin;
}

export function normalizeDocUrl(raw) {
  const input = String(raw || "").trim();
  if (!input) throw new Error("path is required");
  if (input.includes("\\") || input.includes("\0")) throw new Error("Invalid doc path");
  if (input.includes("..") || input.toLowerCase().includes("%2e%2e")) {
    throw new Error("Doc path must not contain ..");
  }

  let url;
  if (input.startsWith("https://") || input.startsWith("http://")) {
    try {
      url = new URL(input);
    } catch {
      throw new Error("Invalid doc URL");
    }
  } else if (input.startsWith("/")) {
    if (input.startsWith("//")) throw new Error("Protocol-relative doc paths are not allowed");
    url = new URL(input, "https://developers.hive.io");
  } else {
    throw new Error("Doc path must be a site path starting with / or a developers.hive.io URL");
  }

  const host = url.hostname.toLowerCase();
  if (!DOC_HOSTS.has(host)) {
    throw new Error(`Doc host ${host} is not allowlisted`);
  }
  if (host === "developers.hive.io" && url.protocol !== "https:") {
    throw new Error("developers.hive.io must be fetched over https");
  }
  if (host === "developers-staging.hive.io" && url.protocol !== "http:" && url.protocol !== "https:") {
    throw new Error("Unsupported staging URL protocol");
  }
  if (url.username || url.password) throw new Error("Doc URL must not include credentials");
  if (isIpHost(host)) throw new Error("IP addresses are not allowed");
  if (url.pathname.includes("..")) throw new Error("Doc path must not contain ..");

  url.hash = "";
  return url;
}

function isIpHost(hostname) {
  const host = hostname.replace(/^\[|\]$/g, "");
  if (/^\d{1,3}(\.\d{1,3}){3}$/.test(host)) return true;
  if (host.includes(":")) return true;
  return false;
}
