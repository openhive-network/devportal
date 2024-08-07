---
title: titles.authentication
position: 4
exclude: true
---
#### User authentication

In Web3 unlike Web2, authenticating user has different meaning. Since only user has and knows their private keys, there should
be a secure way to sign the transaction because there is no concept of Login and applications won't have direct access to user private keys. 
Web3 way of authentication or login, means user has to sign arbitrary message to verify ownership and wallet applications facilitate that.
In Hive, there are services maintained and developed by community. These services help to decrease trust on all new dapps and services.
They help to minimize hacks and private key stealing, phishing attacks done by malicious actors. It is recommended to 
utilize and integrate these services into your website or apps so users can quickly authenticate and start using your app
without fear of loosing their private keys.

#### HiveSigner

This is OAuth2 standard built on top of Hive blockchain. Just like web2 OAuth2 integration, Hivesigner integration works in similar way.

**Application side**
1. Create Hive account for application/website [https://signup.hive.io](https://signup.hive.io).
2. Login with that account into Hivesigner and set account as **Application** from [https://hivesigner.com/profile](https://hivesigner.com/profile).
3. Authorize **hivesigner** with Application account by clicking this link [https://hivesigner.com/authorize/hivesigner](https://hivesigner.com/authorize/hivesigner).
4. Finalize app integration [https://docs.hivesigner.com/h/guides/get-started/hivesigner-oauth2](https://docs.hivesigner.com/h/guides/get-started/hivesigner-oauth2).

**User side**

Overview of steps that user experiences during Login/Authentication in your website or app.

1. Website or application will forward user to Hivesigner.com to authenticate. 
2. Hivesigner after verification/authentication redirects user back website or application with **access token**.
3. Access token used by website or application to sign and broadcast transactions on blockchain.

For more detailed instruction please follow [HiveSigner documentation](https://docs.hivesigner.com/).

HiveSigner SDK: [https://www.npmjs.com/package/hivesigner](https://www.npmjs.com/package/hivesigner)

HiveSigner tutorial: [JS/Node.js]({{ '/tutorials-javascript/hivesigner.html' | relative_url }})

----

#### HiveKeychain

Hive Keychain is an extension for accessing Hive-enabled distributed applications, or "dApps" in your Chromium or Firefox browser!

**Application side**
1. Send a handshake to make sure the extension is installed on browser.
2. Decrypt a message encrypted by a Hive account private key (commonly used for "logging in")
3. Create and sign transaction
4. Broadcast transaction.

**User side**
1. Install Keychain browser extension and import accounts
2. On Login/Authentication popup from website/application, verify message and sign with selected account.
3. Signature used from website/application to sign transactions going forward, every transaction should be signed by user. 

For more detailed instruction please follow [HiveKeychain documentation](https://github.com/hive-keychain/hive-keychain-extension/blob/master/documentation/README.md).

HiveKeychain SDK: [https://www.npmjs.com/package/keychain-sdk](https://www.npmjs.com/package/keychain-sdk)

Keychain tutorial: [JS/Node.js](https://play.hive-keychain.com/)

----

#### HiveAuth

HiveAuth is decentralized solution for any application (either web, desktop or mobile) to easily authenticate 
users without asking them to provide any password or private key.

**Application side**
1. Open a Websocket connection with HAS server.
2. Generate unique auth_key for each user account every time they Login/Authenticate.
3. After user authenticates, auth_key used for broadcasting transactions.

**User side**
1. Install wallet applications that support Hive Auth.
2. On Login/Authentication popup from website/application, verify message with selected account.
3. Unique auth key generated by application for user account used for signing transaction going forward, every transaction should be signed by user. 

For more detailed instruction please follow [HiveAuth documentation](https://docs.hiveauth.com/).

