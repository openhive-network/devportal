Leitfaden zum Erstellen von LLM-Agenten, Automatisierungsbots und Cursor/MCP-ähnlichen Werkzeugen auf Hive. Bevorzuge protokollkompatible Bibliotheken, öffentliche HTTPS-Knoten für Lesezugriffe und eingeschränktes Signieren für Schreibzugriffe.

#### Für wen das gedacht ist

- LLM-Agenten und Coding-Assistenten, die Hive JSON-RPC oder Client-Bibliotheken aufrufen
- Automatisierungsbots, die den Chain-Status beobachten, Daten abrufen und Transaktionen senden
- Cursor-, MCP- oder ähnliche Tool-Integrationen, die einen stabilen Stack und sicheren Key-Umgang brauchen

#### Bevorzugter Stack

Nutze diese Stufenfolge, sofern du keine harte Abhängigkeit von einem Legacy-Client hast:

1. **WAX** ([`@hiveio/wax`](https://www.npmjs.com/package/@hiveio/wax)) — protokollkompatible Transaktions- und Objekthandhabung (TypeScript, C++, Python)
2. **Beekeeper** — Schlüsselverwaltung und Signierung ohne Freigabe von Keys in der Anwendungslogik
3. **Workerbee** ([`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee)) — beobachten, abrufen und Automatisierung auf Basis von WAX und Beekeeper einreichen
4. **DHive / Hive-JS** — Legacy-JavaScript-Clients; geeignet für bestehende Apps, nicht bevorzugt für neue Agentenarbeit

| Komponente | Links |
| --- | --- |
| WAX-Docs | [doc.openhive.network/wax](https://doc.openhive.network/wax/) |
| WAX-Mintlify-Site | [openhive-network-wax.mintlify.app](https://openhive-network-wax.mintlify.app/) |
| WAX-Agentenindex (`llms.txt`) | [mintlify.com/openhive-network/wax/llms.txt](https://mintlify.com/openhive-network/wax/llms.txt) |
| Workerbee | [gitlab.syncad.com/hive/workerbee](https://gitlab.syncad.com/hive/workerbee) · [`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee) |
| Beekeeper | [gitlab.syncad.com/hive/beekeeper](https://gitlab.syncad.com/hive/beekeeper) |
| SDK-Überblick | [SDK Bibliotheken]({{ '/quickstart/#quickstart-choose-library' | relative_url }}) · [SDK-Referenz]({{ '/resources/#resources-sdk-reference' | relative_url }}) |

#### Öffentliche HTTPS-Knoten

Richte schreibgeschütztes JSON-RPC auf eine öffentliche HTTPS-API. Bekannte stabile Endpunkte sind `api.hive.blog`, `api.deathwing.me` und `anyx.io`. Bevorzuge die aktuelle Liste und Gesundheitsdetails unter [Hive Nodes]({{ '/quickstart/#quickstart-hive-full-nodes' | relative_url }}). Hardcode keinen einzelnen Endpoint in Produktionsagenten; rotiere oder falle zurück, wenn ein Knoten ungesund ist.

#### Minimales JSON-RPC-Beispiel

```bash
curl -s --data '{"jsonrpc":"2.0","method":"condenser_api.get_dynamic_global_properties","params":[],"id":1}' https://api.hive.blog
```

Siehe auch [`condenser_api.get_dynamic_global_properties`]({{ '/apidefinitions/#condenser_api.get_dynamic_global_properties' | relative_url }}) und [Understanding Dynamic Global Properties]({{ '/tutorials-recipes/understanding-dynamic-global-properties.html' | relative_url }}).

#### Auth und Schlüsselsicherheit

- Bevorzuge den **posting**-Key (oder von Keychain / Beekeeper verwaltetes Signieren) für Agentenschreibzugriffe, die nur soziale oder `custom_json`-Autorität brauchen
- Lege niemals **active**- oder **owner**-Keys in Agenten-Prompts, Chat-Logs, CI-Ausgabe oder clientseitigem Quellcode ab
- Plane **Resource Credits (RC)** vor hochfrequentem Broadcast ein; siehe [RC API]({{ '/apidefinitions/#apidefinitions-rc-api' | relative_url }}) und das [RC-Demo (Python)]({{ '/tutorials-python/rcdemo.html' | relative_url }})
- Für interaktive Login-Flows siehe [Authentifizierung]({{ '/quickstart/#quickstart-authentication' | relative_url }}) (HiveSigner, Keychain, HiveAuth)

#### App-Daten und Analytik

- Nutze **`custom_json`**-Operationen für anwendungsspezifische Payloads (id + JSON-Body), statt Posts zu überladen, wenn du nur strukturierten App-State brauchst. Beispielmuster: [Tic-Tac-Toe game]({{ '/tutorials-javascript/tic-tac-toe-game.html' | relative_url }})
- Für leseintensive Analyse-Agenten bevorzuge **HAF** (Hive Application Framework) SQL/API-Zugriff statt Condenser-Endpoints zu überlasten. Siehe [Setup HAF API node]({{ '/nodeop/haf-api.html' | relative_url }})

#### Maschinenlesbarer Portal-Index

Dieses Portal veröffentlicht einen agentenorientierten Link-Dump unter [https://developers.hive.io/llms.txt](https://developers.hive.io/llms.txt). Kombiniere ihn mit dem WAX-Mintlify-`llms.txt` oben, wenn du Hive-Tooling aufsetzt.
