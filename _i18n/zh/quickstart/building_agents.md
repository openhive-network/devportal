在 Hive 上构建 LLM 代理、自动化机器人以及 Cursor/MCP 风格工具的指南。读取优先使用协议兼容库和公共 HTTPS 节点，写入使用受限签名。

#### 适用对象

- 调用 Hive JSON-RPC 或客户端库的 LLM 代理与编程助手
- 观察链状态、获取数据并提交交易的自动化机器人
- 需要稳定技术栈与安全密钥处理的 Cursor、MCP 或类似工具集成

#### 推荐技术栈

除非你硬性依赖旧版客户端，否则按此层级选择：

1. **WAX** ([`@hiveio/wax`](https://www.npmjs.com/package/@hiveio/wax)) — 协议兼容的交易与对象处理（TypeScript、C++、Python）
2. **Beekeeper** — 在应用逻辑中不暴露密钥的密钥管理与签名
3. **Workerbee** ([`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee)) — 基于 WAX 与 Beekeeper 进行观察、获取与提交自动化
4. **DHive / Hive-JS** — 旧版 JavaScript 客户端；适用于现有应用，不推荐用于新的代理开发

| 组件 | 链接 |
| --- | --- |
| WAX 文档 | [doc.openhive.network/wax](https://doc.openhive.network/wax/) |
| WAX Mintlify 站点 | [openhive-network-wax.mintlify.app](https://openhive-network-wax.mintlify.app/) |
| WAX 代理索引（`llms.txt`） | [mintlify.com/openhive-network/wax/llms.txt](https://mintlify.com/openhive-network/wax/llms.txt) |
| Workerbee | [gitlab.syncad.com/hive/workerbee](https://gitlab.syncad.com/hive/workerbee) · [`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee) |
| Beekeeper | [gitlab.syncad.com/hive/beekeeper](https://gitlab.syncad.com/hive/beekeeper) |
| SDK 概览 | [SDK 库]({{ '/quickstart/#quickstart-choose-library' | relative_url }}) · [SDK 参考]({{ '/resources/#resources-sdk-reference' | relative_url }}) |

#### 公共 HTTPS 节点

将只读 JSON-RPC 指向公共 HTTPS API。已知稳定节点包括 `api.hive.blog`、`api.deathwing.me` 和 `anyx.io`。请优先参考 [Hive Nodes]({{ '/quickstart/#quickstart-hive-full-nodes' | relative_url }}) 上的实时列表与健康状态。不要在生产代理中硬编码单一 endpoint；节点不健康时应轮换或回退。

#### 最小 JSON-RPC 示例

```bash
curl -s --data '{"jsonrpc":"2.0","method":"condenser_api.get_dynamic_global_properties","params":[],"id":1}' https://api.hive.blog
```

另见 [`condenser_api.get_dynamic_global_properties`]({{ '/apidefinitions/#condenser_api.get_dynamic_global_properties' | relative_url }}) 与 [Understanding Dynamic Global Properties]({{ '/tutorials-recipes/understanding-dynamic-global-properties.html' | relative_url }})。

#### 认证与密钥安全

- 对仅需社交或 `custom_json` 权限的代理写入，优先使用 **posting** 密钥（或 Keychain / Beekeeper 管理的签名）
- 切勿将 **active** 或 **owner** 密钥放入代理提示、聊天日志、CI 输出或客户端源码
- 高频广播前预留 **resource credits (RC)**；参见 [RC API]({{ '/apidefinitions/#apidefinitions-rc-api' | relative_url }}) 与 [RC 演示（Python）]({{ '/tutorials-python/rcdemo.html' | relative_url }})
- 交互式登录流程见 [认证]({{ '/quickstart/#quickstart-authentication' | relative_url }})（HiveSigner、Keychain、HiveAuth）

#### 应用数据与分析

- 当只需结构化应用状态时，使用 **`custom_json`** 操作承载应用专用载荷（id + JSON body），而不是滥用帖子。示例模式：[Tic-Tac-Toe game]({{ '/tutorials-javascript/tic-tac-toe-game.html' | relative_url }})
- 对于读密集型分析代理，优先使用 **HAF**（Hive Application Framework）SQL/API，而不是频繁冲击 condenser 接口。参见 [Setup HAF API node]({{ '/nodeop/haf-api.html' | relative_url }})


#### 参考 MCP 服务器

本仓库的 `mcp/` 目录是只读 [MCP](https://modelcontextprotocol.io) 服务器。工具由已发布的 [OpenRPC](https://developers.hive.io/openrpc.json) 文档生成。它不签名、不保存密钥，并且在未显式开启时拒绝 broadcast 方法。没有公共托管端点；请在本地通过 stdio 运行。

- `list_methods` / `get_method_schema` — 从 `/openrpc.json` 发现方法
- `hive_rpc_call` — 向允许列表中的公共 HTTPS 节点发送 JSON-RPC（默认 `https://api.hive.blog`）
- `fetch_doc_page` — 获取 developers.hive.io 或 staging 页面的纯文本

```bash
cd mcp
npm ci
npm start
```

在生产环境发布 `/openrpc.json` 之前，服务器会回退到 `http://developers-staging.hive.io/openrpc.json`。

除非设置 `HIVE_MCP_ALLOW_BROADCAST=1`，否则 `network_broadcast_api`、`debug_node_api` 和 `broadcast_*` 方法会被拒绝。即便开启，进程也绝不接受私钥——请在服务器之外使用 Beekeeper 或 Keychain 签名。默认限制为每分钟 60 次调用。设计与 Docker：见 [devportal 仓库](https://gitlab.syncad.com/hive/devportal) 中的 `mcp/README.md`。

#### 门户机器可读索引

本门户发布面向代理的链接汇总：[https://developers.hive.io/llms.txt](https://developers.hive.io/llms.txt)。搭建 Hive 工具时，请与上方的 WAX Mintlify `llms.txt` 搭配使用。
