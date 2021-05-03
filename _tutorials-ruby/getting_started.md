---
title: 'RB: Getting Started'
position: 0
description: "To access the Hive blockchain using Ruby, install the Radiator gem: [https://github.com/inertia186/radiator](https://github.com/inertia186/radiator).  Full documentation on Radiator api methods are hosted on [rubydoc.info](https://www.rubydoc.info/gems/radiator)."
layout: full
canonical_url: getting_started.html
---
Full, runnable src of [tutorial_title](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/tutorial_slug) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-tutorial_slug.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/tutorial_slug)).

### Setup

The following is a minimal `Gemfile` for running `.rb` files in these examples.

Add `gem 'radiator'` to your `Gemfile`.  Then install the gem:

```bash
bundle install
```

It is also possible to install `radiator` directly with `gem`:

```bash
gem install radiator
```

Then, to execute a script without a `Gemfile`, add to the top of your `.rb` files:

```ruby
require 'radiator'
```

Then, use the `ruby` command with `radiator` specified:

```bash
ruby -r radiator myscript.rb
```

### Examples

The tutorials on this site are available within this site's repository.  To get a copy, clone this repository, change directory to `devportal/tutorials/ruby/01_blog_feed` and do a `bundle install` to install the required local gems.

From there, you can see each of the `.rb` files referenced on this site, for example:

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/01_blog_feed
bundle install
```

### Typical-Usage

Most methods can be accessed by creating an instance of `Radiator::Api`.  It is also possible to specify a different node by passing a `url` option.

Radiator also internally supports failover by specifying the `failover_urls` option.

To use the defaults:

```ruby
api = Radiator::Api.new
```

To override the `url` option:

```ruby
api = Radiator::Api.new(url: 'https://api.openhive.network')
```

To override both `url` and `failover_urls` options:

```ruby
options = {
  url: 'https://api.openhive.network',
  failover_urls: [
    'https://anyx.io',
    'https://api.hivekings.com',
    'https://hived.privex.io',
  ]
}
api = Radiator::Api.new(options)
```

### Next Step

If you'd like to dive right into the first tutorial, have a look at: [Blog Feed]({{ '/tutorials-ruby/blog_feed.html' | relative_url }})
