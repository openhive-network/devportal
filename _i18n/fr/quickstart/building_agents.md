Guide pour créer des agents LLM, des bots d'automatisation et des outils de type Cursor/MCP sur Hive. Préférez des bibliothèques compatibles avec le protocole, des nœuds HTTPS publics pour les lectures, et une signature contrainte pour les écritures.

#### À qui s'adresse ce guide

- Agents LLM et assistants de code qui appellent le JSON-RPC Hive ou des bibliothèques clientes
- Bots d'automatisation qui observent l'état de la chaîne, récupèrent des données et soumettent des transactions
- Intégrations Cursor, MCP ou similaires qui ont besoin d'une pile stable et d'une gestion sûre des clés

#### Pile recommandée

Utilisez cette échelle sauf dépendance forte à un client historique :

1. **WAX** ([`@hiveio/wax`](https://www.npmjs.com/package/@hiveio/wax)) — gestion des transactions et objets compatible avec le protocole (TypeScript, C++, Python)
2. **Beekeeper** — gestion des clés et signature sans exposer les clés dans la logique applicative
3. **Workerbee** ([`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee)) — observer, récupérer et soumettre de l'automatisation au-dessus de WAX et Beekeeper
4. **DHive / Hive-JS** — clients JavaScript historiques ; convenables pour les apps existantes, non préférés pour un nouveau travail d'agent

| Composant | Liens |
| --- | --- |
| Docs WAX | [doc.openhive.network/wax](https://doc.openhive.network/wax/) |
| Site Mintlify WAX | [openhive-network-wax.mintlify.app](https://openhive-network-wax.mintlify.app/) |
| Index agent WAX (`llms.txt`) | [mintlify.com/openhive-network/wax/llms.txt](https://mintlify.com/openhive-network/wax/llms.txt) |
| Workerbee | [gitlab.syncad.com/hive/workerbee](https://gitlab.syncad.com/hive/workerbee) · [`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee) |
| Beekeeper | [gitlab.syncad.com/hive/beekeeper](https://gitlab.syncad.com/hive/beekeeper) |
| Aperçu SDK | [Librairies SDK]({{ '/quickstart/#quickstart-choose-library' | relative_url }}) · [Référence SDK]({{ '/resources/#resources-sdk-reference' | relative_url }}) |

#### Nœuds HTTPS publics

Pointez le JSON-RPC en lecture seule vers une API HTTPS publique. Des nœuds stables connus incluent `api.hive.blog`, `api.deathwing.me` et `anyx.io`. Préférez la liste en direct et l'état de santé sur [Hive Nodes]({{ '/quickstart/#quickstart-hive-full-nodes' | relative_url }}). Ne codez pas en dur un seul endpoint dans les agents de production ; basculez ou faites un fallback quand un nœud est en mauvaise santé.

#### Exemple JSON-RPC minimal

```bash
curl -s --data '{"jsonrpc":"2.0","method":"condenser_api.get_dynamic_global_properties","params":[],"id":1}' https://api.hive.blog
```

Voir aussi [`condenser_api.get_dynamic_global_properties`]({{ '/apidefinitions/#condenser_api.get_dynamic_global_properties' | relative_url }}) et [Understanding Dynamic Global Properties]({{ '/tutorials-recipes/understanding-dynamic-global-properties.html' | relative_url }}).

#### Auth et sécurité des clés

- Préférez la clé **posting** (ou une signature gérée par Keychain / Beekeeper) pour les écritures d'agent qui n'ont besoin que d'une autorité sociale ou `custom_json`
- Ne placez jamais de clés **active** ou **owner** dans les prompts d'agent, les journaux de chat, la sortie CI ou le code côté client
- Budgétez les **resource credits (RC)** avant un broadcast haute fréquence ; voir [RC API]({{ '/apidefinitions/#apidefinitions-rc-api' | relative_url }}) et la [démo RC (Python)]({{ '/tutorials-python/rcdemo.html' | relative_url }})
- Pour les flux de connexion interactifs, voir [Authentification]({{ '/quickstart/#quickstart-authentication' | relative_url }}) (HiveSigner, Keychain, HiveAuth)

#### Données applicatives et analytique

- Utilisez des opérations **`custom_json`** pour des charges utiles spécifiques à l'application (id + corps JSON) au lieu de surcharger les posts quand vous n'avez besoin que d'un état structuré. Motif d'exemple : [Tic-Tac-Toe game]({{ '/tutorials-javascript/tic-tac-toe-game.html' | relative_url }})
- Pour des agents d'analytique à forte lecture, préférez l'accès SQL/API **HAF** (Hive Application Framework) plutôt que de marteler les endpoints condenser. Voir [Setup HAF API node]({{ '/nodeop/haf-api.html' | relative_url }})


#### Serveur MCP de référence

Le répertoire `mcp/` de ce dépôt est un serveur [MCP](https://modelcontextprotocol.io) en lecture seule. Les outils sont produits à partir du document [OpenRPC](https://developers.hive.io/openrpc.json). Il ne signe pas, ne conserve pas de clés et refuse les méthodes de broadcast sauf opt-in. Pas d'endpoint public : exécution locale en stdio.

- `list_methods` / `get_method_schema` — découvrir les méthodes de `/openrpc.json`
- `hive_rpc_call` — JSON-RPC vers un nœud HTTPS public autorisé (`https://api.hive.blog` par défaut)
- `fetch_doc_page` — texte d'une page developers.hive.io ou staging

```bash
cd mcp
npm ci
npm start
```

Tant que la production ne publie pas `/openrpc.json`, le serveur se rabat sur `http://developers-staging.hive.io/openrpc.json`.

`network_broadcast_api`, les méthodes `broadcast_*` et les mutateurs spécialisés (par exemple `chain_api.push_transaction`) restent interdits sans `HIVE_MCP_ALLOW_BROADCAST=1`. `debug_node_api` — y compris les méthodes porteuses de clé `debug_generate_blocks*` — reste interdit même avec cette option. Le processus n'accepte jamais de clé privée : signez avec Beekeeper ou Keychain en dehors du serveur MCP. Limite par défaut : 60 appels par minute (`HIVE_MCP_RATE_LIMIT`). Conception et Docker : `mcp/README.md` dans le [dépôt devportal](https://gitlab.syncad.com/hive/devportal).

#### Index lisible par machine du portail

Ce portail publie un dump de liens orienté agents sur [https://developers.hive.io/llms.txt](https://developers.hive.io/llms.txt). Associez-le au `llms.txt` WAX Mintlify ci-dessus lors de l'échafaudage d'outils Hive.
