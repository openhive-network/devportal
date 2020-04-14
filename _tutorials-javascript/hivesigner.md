---
title: 'JS: Hivesigner'
position: 2
description: "_Understand the basics of using Hivesigner with your Hive application._"
layout: full
---              
<span class="fa-pull-left top-of-tutorial-repo-link"><span class="first-word">Full</span>, runnable src of [Hivesigner](https://gitlab.syncad.com/hive/devportal/-/tree/develop/tutorials/devportal-tutorials-js/tutorials/02_hivesigner) can be downloaded as part of: [tutorials/devportal-tutorials-js](https://gitlab.syncad.com/hive/devportal/-/tree/develop/tutorials/devportal-tutorials-js).</span>
<br>



In this tutorial we will setup Hivesigner for demo application and step by step show the process of setting up dedicated account for your app to use Hivesigner Dashboard and setup backend of your application to use Hivesigner authorization properly.

## Intro

The application in this tutorial asks the user to grant an access to `demo-app` and get token from Hivesigner. Once permission is granted, `demo-app` can get details of user via an api call that requires access token.
Purpose is to allow any application request permission from user and perform action via access token.

Some other calls that require an access token (or login) are:

*   Vote
*   Comment
*   Post
*   Follow
*   Reblog

Learn more about [Hivesigner operations here](https://github.com/ledgerconnect/hivesigner.js)

## Steps

1.  [**Hivesigner Dashboard**](#dashboard) Create account for application and set up dashboard
1.  [**Initialize Hivesigner**](#init) Initialize SDK in your application code
1.  [**Login URL**](#login-url) Form login url for user
1.  [**Request token**](#request-token) Request token with login url
1.  [**Set token**](#set-token) Set or save token for future requests
1.  [**Get user data**](#get-user) Get user details with token
1.  [**Logout**](#logout) Logout user and clear token

#### 1. Hivesigner Dashboard<a name="dashboard"></a>

Hivesigner is unified authentification system built on top of Hive.
Layer to ensure easy access and setup for all application developers as well as secure way for users to interact with Hive apps.

Setting up Hivesigner in your app is straight-forward process and never been this easy.

Here are the steps that helps you to setup new app:

1a. Visit [Hivesigner Dashboard](https://hivesigner.com/profile) and login with your Hive credentials for your app

![hivesigner_login](https://gitlab.syncad.com/hive/devportal/-/raw/master/tutorials/devportal-tutorials-js/tutorials/02_hivesigner/images/hivesigner_login.png)

1b. You will see Account type, User and Application section, in Application section fill out details of App

![hivesigner_dashboard](https://gitlab.syncad.com/hive/devportal/-/raw/master/tutorials/devportal-tutorials-js/tutorials/02_hivesigner/images/account_type_application.png)

1c. Give your app name, description, icon image link, website (if available) and Redirect URI(s)

Here is an example of [Esteem](https://esteem.app) form to give you idea how to fill form correctly.

![hivesigner_myapps](https://gitlab.syncad.com/hive/devportal/-/raw/master/tutorials/devportal-tutorials-js/tutorials/02_hivesigner/images/hivesigner_myapp.png)

Application name and description should give users clear understanding what permissions it requires and what is the purpose of the app.

App Icon field should be publicly accessible and available link to your logo or icon.

Website field is homepage for the application if exist.

Redirect URI(s) will be used within your application to forward user after authentification is successful. You can specify multiple callback URLs with each new line. Callback in Hivesigner SDK should match exactly one of URI(s) specified on this page. Due to security reasons if redirect URI(s) used in SDK is other than you specified, it will not work.
This is typical backend web development, we hope you know how to set up your backend/app to handle callback URLs.

*   Disclaimer: All images/screenshots of user interface may change as Hivesigner evolves

#### 2. Initialize Hivesigner<a name="init"></a>

Once you have setup account for new application, you can setup application with Hivesigner authentification and API processes.
To do that, you will need to install `hivesigner` nodejs package with `npm i hivesigner`.
Within application you can initialize Hivesigner

> `app` - is account name for application that we have created in Step I.3, `callbackURL` - is Redirect URI that we have defined in Step I.4, `scope` - permissions application is requiring/asking from users

Now that `hivesigner` is initialized we can start authentication and perform simple operations with Hivesigner.

#### 3. Login URL<a name="login-url"></a>

> `getLoginURL` function you see on the right side, returns login URL which will redirect user to sign in with Hivesigner screen. Successfull login will redirect user to Redirect URI or `callbackURL`. Result of successful login will return `access_token`, `expires_in` and `username` information, which application will start utilizing.

#### 4. Request token<a name="request-token"></a>

> Application can request returned link into popup screen or relevant screen you have developed. Popup screen will ask user to identify themselves with their username and password. Once login is successful, you will have Results

#### 5. Set token<a name="set-token"></a>

> Returned data has `access_token` - which will be used in future api calls, `expires_in` - how long access token is valid in seconds and `username` of logged in user.

> After getting `access_token`, we can set token for future Hivesigner API requests.

#### 6. Get user data<a name="get-user"></a>

> Users info can be checked with `me` which will return object
> `account` - current state of account and its details on Hive blockchain, `name` - username, `scope` - permissions allowed with current login, `user` - username, `user_metadata` - additional information user has setup.

#### 7. Logout<a name="logout"></a>

> In order to logout, you can use `revokeToken` function from hivesigner.

**That's all there is to it.**

### To Run the tutorial

1.  `git clone https://gitlab.syncad.com/hive/devportal.git`
1.  `cd devportal/tutorials/devportal-tutorials-js/tutorials/02_hivesigner`
1.  `npm i`
1.  `npm run dev-server` or `npm run start`
1.  After a few moments, the server should be running at [http://localhost:3000/](http://localhost:3000/)


---
