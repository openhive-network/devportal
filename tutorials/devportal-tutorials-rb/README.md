# devportal-tutorials-rb

_Ruby Tutorials for the Developer Portal_

These examples/tutorials will familiarize you with the basics of operating on the steem blockchain.

Each tutorial is located in its own folder, and has a README.md with an outline of the basic concepts
and operations it intends to teach.

The tutorials build on each other. It's suggested you go through them in-order.

## Tutorial List

0. [Getting Started](tutorials/00_getting_started) - Common tasks for getting ruby apps to access the blockchain
1.  [Blog Feed](tutorials/01_blog_feed) - Pull the list of a user's posts from the blockchain
11. [Submit Comment Reply](tutorials/11_submit_comment_reply) - Broadcast a reply to the blockchain using the values provided

## To Run one of the tutorials

Use the command line/terminal for the following instructions

1.  `git clone https://gitlab.syncad.com/hive/devportal.git`

    `git clone git@github.com:steemit/devportal-tutorials-rb.git`

1.  cd into the tutorial you wish to run, e.g.:

    ex: `cd devportal-tutorials-rb/tutorials/01_blog_feed`

1.  Use Bundler to install dependencies

    `bundle install`

1.  Run the tutorial, e.g.:

    `ruby blog_feed.rb steemitblog`

## Contributing

If you're interested in contributing a tutorial to this repo. Please have a look at
[the guidelines](./tutorials/tutorial_structure.md) for the text portion of the tutorial..
