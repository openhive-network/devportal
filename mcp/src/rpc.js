export function buildRpcRequest(method, params) {
  const structure = method.paramStructure || "by-name";
  let rpcParams;
  if (structure === "by-position") {
    if (params == null) rpcParams = [];
    else if (Array.isArray(params)) rpcParams = params;
    else throw new Error(`${method.name} uses positional params; pass a JSON array`);
  } else if (params == null) {
    rpcParams = {};
  } else if (Array.isArray(params)) {
    throw new Error(`${method.name} uses named params; pass a JSON object`);
  } else if (typeof params !== "object") {
    throw new Error("params must be an object or array");
  } else {
    rpcParams = params;
  }
  return {
    jsonrpc: "2.0",
    method: method.name,
    params: rpcParams,
    id: 1,
  };
}

export function htmlToText(html) {
  return String(html)
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&#39;|&apos;/g, "'")
    .replace(/&quot;/g, '"')
    .replace(/\s+/g, " ")
    .trim();
}
