---
title: titles.blog_feed
position: 1
description: "This tutorial shows you how to get blogs details from the specified author, limited to five results."
layout: full
canonical_url: blog_feed.html
---

### Introduction

In this tutorial, we will see how to get blog feed from the selected author with [hive-php-lib](https://gitlab.syncad.com/hive/hive-php-lib). You can also find the result PHP file in the `/resources/examples/blogFeed.php` file in `hive-php-lib` folder.

Also see:
* [get_discussions_by_blog]({{ '/apidefinitions/#condenser_api.get_discussions_by_blog' | relative_url }})

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

Now, use the `getDiscussionByBlog` function.

This function needs two variables to work:

- `$tag`: (string) to have the author to fetch,
- `$limit`: (int) to know how much posts to fetch.

```php
$tag = 'bambukah';
$limit = 5;

$result = $hiveApi->getDiscussionsByBlog($tag, $limit);
```

`$result` will be an array with all data. To display them, just `print_r()` the first element:

```php
print_r($result[0]);
```

Now, you have an array with five posts from @bambukah and you have all the details for each post.
