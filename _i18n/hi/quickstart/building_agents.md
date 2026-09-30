Hive पर LLM एजेंट, ऑटोमेशन बॉट और Cursor/MCP-शैली टूल बनाने के लिए गाइड। रीड के लिए प्रोटोकॉल-संगत लाइब्रेरी, सार्वजनिक HTTPS नोड, और राइट के लिए सीमित साइनिंग को प्राथमिकता दें।

#### यह किसके लिए है

- LLM एजेंट और कोडिंग असिस्टेंट जो Hive JSON-RPC या क्लाइंट लाइब्रेरी कॉल करते हैं
- ऑटोमेशन बॉट जो चेन स्टेट देखते हैं, डेटा प्राप्त करते हैं, और ट्रांज़ैक्शन सबमिट करते हैं
- Cursor, MCP, या समान टूल इंटीग्रेशन जिन्हें स्थिर स्टैक और सुरक्षित कुंजी प्रबंधन चाहिए

#### पसंदीदा स्टैक

जब तक आपके पास लेगेसी क्लाइंट पर कठोर निर्भरता न हो, इस क्रम का उपयोग करें:

1. **WAX** ([`@hiveio/wax`](https://www.npmjs.com/package/@hiveio/wax)) — प्रोटोकॉल-संगत ट्रांज़ैक्शन और ऑब्जेक्ट हैंडलिंग (TypeScript, C++, Python)
2. **Beekeeper** — एप्लिकेशन लॉजिक में कुंजियाँ उजागर किए बिना कुंजी प्रबंधन और साइनिंग
3. **Workerbee** ([`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee)) — WAX और Beekeeper के ऊपर ऑब्ज़र्व, फ़ेच और ऑटोमेशन सबमिट
4. **DHive / Hive-JS** — लेगेसी JavaScript क्लाइंट; मौजूदा ऐप्स के लिए ठीक, नए एजेंट कार्य के लिए पसंदीदा नहीं

| घटक | लिंक |
| --- | --- |
| WAX docs | [doc.openhive.network/wax](https://doc.openhive.network/wax/) |
| WAX Mintlify साइट | [openhive-network-wax.mintlify.app](https://openhive-network-wax.mintlify.app/) |
| WAX एजेंट इंडेक्स (`llms.txt`) | [mintlify.com/openhive-network/wax/llms.txt](https://mintlify.com/openhive-network/wax/llms.txt) |
| Workerbee | [gitlab.syncad.com/hive/workerbee](https://gitlab.syncad.com/hive/workerbee) · [`@hiveio/workerbee`](https://www.npmjs.com/package/@hiveio/workerbee) |
| Beekeeper | [gitlab.syncad.com/hive/beekeeper](https://gitlab.syncad.com/hive/beekeeper) |
| SDK अवलोकन | [SDK Libraries]({{ '/quickstart/#quickstart-choose-library' | relative_url }}) · [SDK Reference]({{ '/resources/#resources-sdk-reference' | relative_url }}) |

#### सार्वजनिक HTTPS नोड

रीड-ओनली JSON-RPC को किसी सार्वजनिक HTTPS API पर इंगित करें। ज्ञात स्थिर नोड में `api.hive.blog`, `api.deathwing.me`, और `anyx.io` शामिल हैं। लाइव सूची और स्वास्थ्य विवरण के लिए [Hive Nodes]({{ '/quickstart/#quickstart-hive-full-nodes' | relative_url }}) को प्राथमिकता दें। प्रोडक्शन एजेंट में एक ही endpoint हार्ड-कोड न करें; नोड अस्वस्थ होने पर रोटेट करें या fallback करें।

#### न्यूनतम JSON-RPC उदाहरण

```bash
curl -s --data '{"jsonrpc":"2.0","method":"condenser_api.get_dynamic_global_properties","params":[],"id":1}' https://api.hive.blog
```

यह भी देखें: [`condenser_api.get_dynamic_global_properties`]({{ '/apidefinitions/#condenser_api.get_dynamic_global_properties' | relative_url }}) और [Understanding Dynamic Global Properties]({{ '/tutorials-recipes/understanding-dynamic-global-properties.html' | relative_url }})।

#### प्रमाणीकरण और कुंजी सुरक्षा

- केवल सोशल या `custom_json` authority की ज़रूरत वाले एजेंट राइट के लिए **posting** कुंजी (या Keychain / Beekeeper-प्रबंधित साइनिंग) को प्राथमिकता दें
- **active** या **owner** कुंजियाँ कभी भी एजेंट प्रॉम्प्ट, चैट लॉग, CI आउटपुट, या क्लाइंट-साइड सोर्स में न रखें
- उच्च-आवृत्ति broadcast से पहले **resource credits (RC)** का बजट बनाएँ; देखें [RC API]({{ '/apidefinitions/#apidefinitions-rc-api' | relative_url }}) और [RC डेमो (Python)]({{ '/tutorials-python/rcdemo.html' | relative_url }})
- इंटरैक्टिव लॉगिन फ़्लो के लिए देखें [प्रमाणीकरण]({{ '/quickstart/#quickstart-authentication' | relative_url }}) (HiveSigner, Keychain, HiveAuth)

#### ऐप डेटा और एनालिटिक्स

- जब आपको केवल संरचित ऐप स्टेट चाहिए, पोस्ट पर बोझ डालने के बजाय ऐप-विशिष्ट payload (id + JSON body) के लिए **`custom_json`** ऑपरेशन उपयोग करें। उदाहरण पैटर्न: [Tic-Tac-Toe game]({{ '/tutorials-javascript/tic-tac-toe-game.html' | relative_url }})
- रीड-हेवी एनालिटिक्स एजेंट के लिए condenser endpoints पर दबाव डालने के बजाय **HAF** (Hive Application Framework) SQL/API एक्सेस को प्राथमिकता दें। देखें [Setup HAF API node]({{ '/nodeop/haf-api.html' | relative_url }})


#### संदर्भ MCP सर्वर

इस रिपॉज़िटरी की `mcp/` डायरेक्टरी एक रीड-ओनली [MCP](https://modelcontextprotocol.io) सर्वर है। टूल प्रकाशित [OpenRPC](https://developers.hive.io/openrpc.json) दस्तावेज़ से बनते हैं। यह साइन नहीं करता, कुंजियाँ नहीं रखता, और ऑप्ट-इन के बिना broadcast मेथड अस्वीकार करता है। कोई सार्वजनिक एंडपॉइंट नहीं है; इसे लोकल stdio पर चलाएँ।

- `list_methods` / `get_method_schema` — `/openrpc.json` से मेथड खोजें
- `hive_rpc_call` — अनुमति-सूची वाले सार्वजनिक HTTPS नोड पर JSON-RPC (`https://api.hive.blog` डिफ़ॉल्ट)
- `fetch_doc_page` — developers.hive.io या staging पृष्ठ का सादा पाठ

```bash
cd mcp
npm ci
npm start
```

जब तक प्रोडक्शन `/openrpc.json` प्रकाशित नहीं करता, सर्वर `http://developers-staging.hive.io/openrpc.json` पर वापस जाता है।

`network_broadcast_api`, `debug_node_api`, और `broadcast_*` मेथड `HIVE_MCP_ALLOW_BROADCAST=1` के बिना बंद रहते हैं। तब भी प्रक्रिया निजी कुंजी स्वीकार नहीं करती — Beekeeper या Keychain से सर्वर के बाहर साइन करें। डिफ़ॉल्ट सीमा: 60 कॉल प्रति मिनट। डिज़ाइन और Docker: [devportal रिपॉज़िटरी](https://gitlab.syncad.com/hive/devportal) में `mcp/README.md`।

#### पोर्टल मशीन-रीडेबल इंडेक्स

यह पोर्टल एजेंट-उन्मुख लिंक डंप प्रकाशित करता है: [https://developers.hive.io/llms.txt](https://developers.hive.io/llms.txt)। Hive टूलिंग स्कैफ़ोल्ड करते समय इसे ऊपर दिए गए WAX Mintlify `llms.txt` के साथ जोड़ें।
