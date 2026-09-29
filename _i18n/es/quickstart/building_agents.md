Guía para crear agentes LLM, bots de automatización y herramientas tipo Cursor/MCP sobre Hive. Prefiere bibliotecas compatibles con el protocolo, nodos HTTPS públicos para lecturas y firmas restringidas para escrituras.

#### Para quién es esto

- Agentes LLM y asistentes de código que llaman a JSON-RPC de Hive o a bibliotecas cliente
- Bots de automatización que observan el estado de la cadena, obtienen datos y envían transacciones
- Integraciones con Cursor, MCP u herramientas similares que necesitan una pila estable y un manejo seguro de claves

#### Pila recomendada

Usa esta escala salvo que tengas una dependencia fuerte de un cliente legado:

1. **WAX** ([`@hiveio/wax`](https://www.npmjs.com/package/@hiveio/wax)) — manejo de transacciones y objetos compatible con el protocolo (TypeScript, C++, Python)
2. **Beekeeper** — gestión de claves y firma sin exponer claves en la lógica de la aplicación
3. **Workerbee** ([`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee)) — observar, obtener y enviar automatización sobre WAX y Beekeeper
4. **DHive / Hive-JS** — clientes JavaScript legados; válidos para apps existentes, no preferidos para trabajo nuevo con agentes

| Componente | Enlaces |
| --- | --- |
| Docs de WAX | [doc.openhive.network/wax](https://doc.openhive.network/wax/) |
| Sitio Mintlify de WAX | [openhive-network-wax.mintlify.app](https://openhive-network-wax.mintlify.app/) |
| Índice para agentes de WAX (`llms.txt`) | [mintlify.com/openhive-network/wax/llms.txt](https://mintlify.com/openhive-network/wax/llms.txt) |
| Workerbee | [gitlab.syncad.com/hive/workerbee](https://gitlab.syncad.com/hive/workerbee) · [`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee) |
| Beekeeper | [gitlab.syncad.com/hive/beekeeper](https://gitlab.syncad.com/hive/beekeeper) |
| Resumen SDK | [Bibliotecas SDK]({{ '/quickstart/#quickstart-choose-library' | relative_url }}) · [Referencia SDK]({{ '/resources/#resources-sdk-reference' | relative_url }}) |

#### Nodos HTTPS públicos

Apunta el JSON-RPC de solo lectura a una API HTTPS pública. Nodos estables conocidos incluyen `api.hive.blog`, `api.deathwing.me` y `anyx.io`. Prefiere la lista en vivo y el estado de salud en [Hive Nodes]({{ '/quickstart/#quickstart-hive-full-nodes' | relative_url }}). No hardcodees un único endpoint en agentes de producción; rota o haz fallback cuando un nodo no esté sano.

#### Ejemplo mínimo de JSON-RPC

```bash
curl -s --data '{"jsonrpc":"2.0","method":"condenser_api.get_dynamic_global_properties","params":[],"id":1}' https://api.hive.blog
```

Consulta también [`condenser_api.get_dynamic_global_properties`]({{ '/apidefinitions/#condenser_api.get_dynamic_global_properties' | relative_url }}) y [Understanding Dynamic Global Properties]({{ '/tutorials-recipes/understanding-dynamic-global-properties.html' | relative_url }}).

#### Autenticación y seguridad de claves

- Prefiere la clave **posting** (o firma gestionada por Keychain / Beekeeper) para escrituras de agentes que solo necesitan autoridad social o de `custom_json`
- Nunca pongas claves **active** u **owner** en prompts de agentes, logs de chat, salida de CI o código del lado del cliente
- Presupuesta **resource credits (RC)** antes de broadcasts de alta frecuencia; consulta [RC API]({{ '/apidefinitions/#apidefinitions-rc-api' | relative_url }}) y el [demo de RC (Python)]({{ '/tutorials-python/rcdemo.html' | relative_url }})
- Para flujos de login interactivos, consulta [Autenticación]({{ '/quickstart/#quickstart-authentication' | relative_url }}) (HiveSigner, Keychain, HiveAuth)

#### Datos de aplicación y analítica

- Usa operaciones **`custom_json`** para cargas específicas de la aplicación (id + cuerpo JSON) en lugar de sobrecargar publicaciones cuando solo necesitas estado estructurado. Patrón de ejemplo: [Tic-Tac-Toe game]({{ '/tutorials-javascript/tic-tac-toe-game.html' | relative_url }})
- Para agentes de analítica con muchas lecturas, prefiere acceso SQL/API de **HAF** (Hive Application Framework) en lugar de saturar los endpoints de condenser. Consulta [Setup HAF API node]({{ '/nodeop/haf-api.html' | relative_url }})

#### Índice legible por máquina del portal

Este portal publica un volcado de enlaces orientado a agentes en [https://developers.hive.io/llms.txt](https://developers.hive.io/llms.txt). Combínalo con el `llms.txt` de WAX Mintlify de arriba al andamiar herramientas Hive.
