---
title: titles.getting_started
position: 0
description: "Before interact with the blockchain, we start with the presentation and configuration of `hive-php-lib`."
layout: full
canonical_url: getting_started.html
---

### Introduction

[hive-php-lib ](https://gitlab.syncad.com/hive/hive-php-lib) try to be the most easier and powerful PHP library to interact with HIVE blockchain.
This is a good choice for all PHP devs:

- All the code is opensource (MIT license), and documented (phpDocumentor),
- [PHP-PDS](http://php-pds.com/) and [PSR standards](https://www.php-fig.org/psr/) are applied to have a more readable code and easier use,
- You can interact with Hive blockchain and HiveEngine layer with the same lib,
- Some shortcuts functions, easy update, and many more...

---

### Installation

Do you know [Composer](https://getcomposer.org/)? It's the PHP package manager and [hive-php-lib](https://gitlab.syncad.com/hive/hive-php-lib) use it to be installed.
It's really easy to use, and the installation is available on the [Composer download page](https://getcomposer.org/download/).

When you are ready with that, just install the lib:

```bash
php composer.phar require hive/hive-php-lib
```

Composer will download and install the library for you.

---

### Preparation

#### Include autoloader

In your PHP file, just add the autoload file:

```php
require __DIR__ . '/vendor/autoload.php';
```

!!! Don't forget to adapt the path !!!

#### Load the needed class

For production use with Hive, we recommend to use the Condenser class :

```php
use Hive\PhpLib\Hive\Condenser as HiveCondenser;
```

#### Create configuration array

[hive-php-lib](https://gitlab.syncad.com/hive/hive-php-lib) need a small configuration array with 4 items :

- hiveNode: (string) the URL of your selected HIVE node,
- heNode: (string) the URL of your selected HiveEngine node,
- debug: (bool) if it's true, it will display the request and the result (Default: false),
- disableSsl: (bool) if it's true, it will disable the SSL verification (Default: false).

here is an example :

```php
$config = [
    "debug" => false,
    "disableSsl" => false,
    "heNode" => "api.hive-engine.com/rpc",
    "hiveNode" =>"anyx.io",
];
```

---

### Usage

Now you just need to instantiate the HiveCondenser object, and you are ready to use any functions of it. Example:

```php
$hiveApi = new HiveCondenser($config);
$result = $hiveApi->findProposal(211); // Will return data about the proposal 211
```

---

### Conclusion

Pretty easy, isn't it? In next tutorials, We will see how to interact directly with HIVE blockchain to retrieve data and how to use most of the functions in this lib.
