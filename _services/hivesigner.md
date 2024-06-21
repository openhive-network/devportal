---
title: titles.hivesigner
position: 5
canonical_url: hivesigner.html
---

**What is Hivesigner?**

The goal of Hivesigner is to provide a safe way of connecting to the blockchain via 3rd party apps without compromising the security of your private keys and passwords. It's a simple identity layer built on top of the blockchain allowing users safe access and developers the freedom of not having to handle the authentication system, i.e. managing users' private keys and encryption. This means that devs won't have to open-source their projects in order to gain user trust. When connecting to apps in this manner, neither Hivesigner nor the authorized app store the private keys as the posting key is encrypted on your cookie.

**How Hivesigner is implemented**

Hivesigner works by granting an access token to the requesting app once the application has been approved.
A full tutorial on how to set up an application, request authorization and grant access can be found [here]({{ '/tutorials-javascript/hivesigner.html' | relative_url }}).

**Hive Authorisation and OAuth 2**

The OAuth protocol allows third party apps to grant limited access to an HTTP service, either on behalf of a resource owner or by allowing the app to obtain access on its own behalf. The authorization is provided without the private key or password of the user being shared with the third party.
Simplified, the process includes the following steps:

1.  The user is presented with an authorization link that requests a token from the API
2.  The user has to log in to the service to verify their identity whereupon they will be prompted to authorize the application
3.  The user is redirected to the application redirect URI along with the access token

Once the application has an access token, it may use the token to access the user's account via the API, limited to the scope of access, until the token expires or is revoked.
A full breakdown of OAuth2 and how it applies to Hive and Hivesigner can be found [here](https://docs.hivesigner.com).

**Useful Links**

*   [Hivesigner Repo](https://github.com/ecency/hivesigner-ui)
*   [Community Resources]({{ '/resources/#resources-hivesigner-libs' | relative_url }})
*   [Hivesigner docs](https://docs.hivesigner.com)

For additional material you can refer to the original Hive [blog](https://ecency.com/hive/@good-karma/hivesigner-released-and-ready) post by [@good-karma](https://ecency.com/@good-karma)
