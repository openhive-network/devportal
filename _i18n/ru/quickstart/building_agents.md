Руководство по созданию LLM-агентов, ботов автоматизации и инструментов в стиле Cursor/MCP на Hive. Предпочитайте протокольно совместимые библиотеки, публичные HTTPS-ноды для чтения и ограниченное подписание для записи.

#### Для кого это

- LLM-агенты и помощники по коду, которые вызывают Hive JSON-RPC или клиентские библиотеки
- Боты автоматизации, которые наблюдают состояние цепи, получают данные и отправляют транзакции
- Интеграции Cursor, MCP или похожих инструментов, которым нужен стабильный стек и безопасная работа с ключами

#### Предпочтительный стек

Используйте эту лестницу, если у вас нет жёсткой зависимости от устаревшего клиента:

1. **WAX** ([`@hiveio/wax`](https://www.npmjs.com/package/@hiveio/wax)) — протокольно совместимая работа с транзакциями и объектами (TypeScript, C++, Python)
2. **Beekeeper** — управление ключами и подписание без раскрытия ключей в логике приложения
3. **Workerbee** ([`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee)) — наблюдение, получение данных и отправка автоматизации поверх WAX и Beekeeper
4. **DHive / Hive-JS** — устаревшие JavaScript-клиенты; подходят для существующих приложений, не предпочтительны для новой агентной работы

| Компонент | Ссылки |
| --- | --- |
| Документация WAX | [doc.openhive.network/wax](https://doc.openhive.network/wax/) |
| Сайт WAX Mintlify | [openhive-network-wax.mintlify.app](https://openhive-network-wax.mintlify.app/) |
| Агентный индекс WAX (`llms.txt`) | [mintlify.com/openhive-network/wax/llms.txt](https://mintlify.com/openhive-network/wax/llms.txt) |
| Workerbee | [gitlab.syncad.com/hive/workerbee](https://gitlab.syncad.com/hive/workerbee) · [`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee) |
| Beekeeper | [gitlab.syncad.com/hive/beekeeper](https://gitlab.syncad.com/hive/beekeeper) |
| Обзор SDK | [Библиотеки SDK]({{ '/quickstart/#quickstart-choose-library' | relative_url }}) · [Справочник SDK]({{ '/resources/#resources-sdk-reference' | relative_url }}) |

#### Публичные HTTPS-ноды

Направляйте JSON-RPC только для чтения на публичный HTTPS API. Известные стабильные ноды включают `api.hive.blog`, `api.deathwing.me` и `anyx.io`. Предпочитайте актуальный список и сведения о здоровье на [Hive Nodes]({{ '/quickstart/#quickstart-hive-full-nodes' | relative_url }}). Не жёстко кодируйте один endpoint в продакшен-агентах; ротируйте или делайте fallback, когда нода нездорова.

#### Минимальный пример JSON-RPC

```bash
curl -s --data '{"jsonrpc":"2.0","method":"condenser_api.get_dynamic_global_properties","params":[],"id":1}' https://api.hive.blog
```

См. также [`condenser_api.get_dynamic_global_properties`]({{ '/apidefinitions/#condenser_api.get_dynamic_global_properties' | relative_url }}) и [Understanding Dynamic Global Properties]({{ '/tutorials-recipes/understanding-dynamic-global-properties.html' | relative_url }}).

#### Аутентификация и безопасность ключей

- Предпочитайте ключ **posting** (или подписание через Keychain / Beekeeper) для записей агента, которым нужна только социальная или `custom_json` authority
- Никогда не помещайте ключи **active** или **owner** в промпты агента, чат-логи, вывод CI или клиентский исходный код
- Планируйте **resource credits (RC)** перед высокочастотным broadcast; см. [RC API]({{ '/apidefinitions/#apidefinitions-rc-api' | relative_url }}) и [демо RC (Python)]({{ '/tutorials-python/rcdemo.html' | relative_url }})
- Для интерактивных потоков входа см. [Аутентификация]({{ '/quickstart/#quickstart-authentication' | relative_url }}) (HiveSigner, Keychain, HiveAuth)

#### Данные приложения и аналитика

- Используйте операции **`custom_json`** для прикладных payload (id + JSON-тело) вместо перегрузки постов, когда нужен только структурированный state. Пример шаблона: [Tic-Tac-Toe game]({{ '/tutorials-javascript/tic-tac-toe-game.html' | relative_url }})
- Для аналитических агентов с большим объёмом чтения предпочитайте SQL/API доступ **HAF** (Hive Application Framework), а не нагрузку на condenser endpoints. См. [Setup HAF API node]({{ '/nodeop/haf-api.html' | relative_url }})


#### Эталонный MCP-сервер

Каталог `mcp/` в этом репозитории — сервер [MCP](https://modelcontextprotocol.io) только для чтения. Инструменты строятся из опубликованного документа [OpenRPC](https://developers.hive.io/openrpc.json). Сервер не подписывает транзакции, не хранит ключи и отклоняет broadcast-методы, пока это явно не включено. Публичной точки доступа нет: процесс локальный, через stdio.

- `list_methods` / `get_method_schema` — методы из `/openrpc.json`
- `hive_rpc_call` — JSON-RPC к разрешённому публичному HTTPS-узлу (по умолчанию `https://api.hive.blog`)
- `fetch_doc_page` — простой текст страницы developers.hive.io или staging

```bash
cd mcp
npm ci
npm start
```

Опубликованные схемы: [https://developers.hive.io/openrpc.json](https://developers.hive.io/openrpc.json) и [https://developers.hive.io/openapi.json](https://developers.hive.io/openapi.json). Переопределите загрузку через `HIVE_OPENRPC_URL` или `HIVE_OPENRPC_PATH`.

`network_broadcast_api`, методы `broadcast_*` и специализированные мутаторы (например `chain_api.push_transaction`) запрещены без `HIVE_MCP_ALLOW_BROADCAST=1`. `debug_node_api` — включая методы с ключом `debug_generate_blocks*` — остаётся запрещённым даже с этим opt-in. Процесс не принимает приватные ключи — подписывайте через Beekeeper или Keychain вне MCP-сервера. Лимит по умолчанию: 60 вызовов в минуту (`HIVE_MCP_RATE_LIMIT`). Дизайн и Docker: `mcp/README.md` в [репозитории devportal](https://gitlab.syncad.com/hive/devportal).

#### Машиночитаемый индекс портала

Этот портал публикует ориентированный на агентов дамп ссылок: [https://developers.hive.io/llms.txt](https://developers.hive.io/llms.txt). Сочетайте его с WAX Mintlify `llms.txt` выше при сборке инструментов Hive.
