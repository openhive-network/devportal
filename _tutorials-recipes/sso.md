---
title: 'Single Sign-on'
position: 1
description: "_Login without authority._"
exclude: true
layout: full
canonical_url: sso.html
---
There are some cases where you don't need Posting Authority on your apps. 

Some examples are [hivesearcher.com](https://hivesearcher.com), [openhive.chat](https://openhive.chat), and [hyperion.zone](https://hyperion.zone) where use case and actions are off-chain, no on-chain operations, or transactions are signed by other means.

These services allow you to login with Hive account and perform actions without any chain operations.  This is perfect use case for off-chain applications.  Essentially, making any Web 2.0 application Web 3.0 by using Blockchain for Authentication. 

There are more benefits of using hybrid approach.  Try these approach and let us know if you are able to secure your apps to the best of your ability.  Giving people complete control over their keys while still allowing services, websites and applications to serve everyone in most secure manner.

---

#### Register Your Application

First, you will need to create a Hive account for your application and then register your application with Hivesigner.

After you have your account, go to [hivesigner.com/profile](https://hivesigner.com/profile) and login with your app account and update account type as "Application" .

#### Create Session

In your application, send your users who wish to log in to the following url:

<blockquote><code>
  https://hivesigner.com/oauth2/authorize?client_id=[YOUR APP HIVE ACCOUNT]&redirect_uri=[YOUR APP DESTINATION]&scope=login
</code></blockquote>

Note, the requested scope is only `login` which will allow your application to authenticate without adding authority.

Be sure to change `[YOUR APP HIVE ACCOUNT]` and `[YOUR APP DESTINATION]`.  Once the user has proven they own the account, Hivesigner will redirect them to the resource you specified, along with an `access_token` parameter.

#### Verify Access Token

Once the user authenticates, they will be redirected back to your application, where you will be able to see the `access_token`, `expires_in` and `username` parameters.

To verify, make a request to [hivesigner.com/api/me](https://hivesigner.com/api/me) using the provided access token and check if it matches the user, e.g.:

```bash
curl -i -H "Authorization: [ACCESS TOKEN]" https://hivesigner.com/api/me
```

Be sure to change `[ACCESS TOKEN]` to the `access_token` that came from the previous redirect.

A valid response will contain status code 200 along with a JSON payload containing the user information while an invalid or expired response will be 401.

Also see: [Hivesigner - Login scope explained](https://ecency.com/hive-139531/@good-karma/hivesigner-login-scope-explained)
