---
title: titles.search_accounts
position: 3
description: "How to call a list of user names from the Hive blockchain"
layout: full
canonical_url: get_post_details.html
---

### Introduction

In this tutorial, we will see how to get accounts list start with the selected string. We made this with [hive-php-lib](https://gitlab.syncad.com/hive/hive-php-lib). You can also find the result PHP file in the `/resources/examples/searchAccounts.php` file in `hive-php-lib` folder.

Also see:
* [lookup_accounts]({{ '/apidefinitions/#condenser_api.lookup_account' | relative_url }})

---

### Preparation

Before start to code, don't forget to read the [PHP: Getting Started]( {{ '/tutorials-php/getting_started.html' | relative_url }} ) tutorial to see how to prepare your code for [hive-php-lib](https://gitlab.syncad.com/hive/hive-php-lib).
If you want a shortcut, just start your PHP file with:

```php
<?php

/* Load Composer for autoload libs */
require __DIR__ . '/vendor/autoload.php';

/* Declase use statement to add Hive Condenser lib */
use Hive\PhpLib\Hive\Condenser as HiveCondenser;

/* Create config array and fill with settings */
$config = [
    "debug" => false,
    "disableSsl" => false,
    "heNode" => "api.hive-engine.com/rpc",
    "hiveNode" =>"anyx.io",
];

/* Instantiate Hive Condenser object */
$hiveApi = new HiveCondenser($config);
```

---

### Query

Now, use the `lookupAccounts` function. This function must have 2 arguments:

- `$lowerBound`: (string) the selected string,
- `$limùit`:(int)number of records to display.

```php
$lowerBound = 'bamb';
$limit = 10;

$result = $hiveApi->lookupAccounts($lowerBound, $limit);
```

Now, you have an array (`$result`) with 10 first accounts name started with "bamb". To display them, just `print_r()`:

```php
print_r($result);
```


