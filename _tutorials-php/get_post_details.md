---
title: titles.get_post_details
position: 2
description: descriptions.get_post_details
layout: full
canonical_url: get_post_details.html
---

### Introduction

In this tutorial, we will see how to get details from only one post with [hive-php-lib](https://gitlab.syncad.com/hive/hive-php-lib). You can also find the result PHP file in the `/resources/examples/getPostDetails.php` file in `hive-php-lib` folder.

Also see:
* [get_content]({{ '/apidefinitions/#condenser_api.get_content' | relative_url }})

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

Now, use the `getContent` function. This function must have 2 arguments:

- `$author`: (string) the author of the post,
- `$permlink`:(string) the slugified perm link to the post.

```php
$tag = 'bambukah';
$permlink ='fun-with-diy-some-stuff';

$result = $api->getContent($tag, $limit);
```

Now, you have an array (`$result`) with all details from `@bambukah/fun-with-diy-some-stuff` post. To display them, just `print_r()`:

```php
print_r($result);
```


