---
title: titles.getting_started
position: 0
description: descriptions.getting_started
layout: full
canonical_url: getting_started.html
---
Full, runnable src of these tutorials can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript) (or download just the JavaScript tutorials: [devportal-master-tutorials-javascript.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/javascript)).

For Javascript tutorials, we will use the opensource library [@hiveio/dhive](https://gitlab.syncad.com/hive/dhive).

### Node.js

To get the most out of these tutorials, you should be familiar with [Node.js](https://nodejs.org/en/), [ES6](https://babeljs.io/learn-es2015/) aka [es2015](https://www.ecma-international.org/ecma-262/6.0/), the DOM, and modern Javascript programming practices.
You can still learn a lot of these if they aren't in your base skill-set; it'll be much easier if they are.

### Your Dev Environment

These tutorials require [Node.js 8.7+](https://nodejs.org/en/download/). [Yarn](https://yarnpkg.com/en/) is nice, but not required. Runnable versions of the tutorials are located [in this github repo](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/javascript).
If you haven't chosen an editor, you can use [Atom](https://atom.io/), [Sublime](https://www.sublimetext.com/), [Intellij](https://www.jetbrains.com/idea/), [Vi](https://en.wikipedia.org/wiki/Vi), etc.

If you want to keep multiple versions of Node on your system try [Node Version Manager](https://github.com/creationix/nvm).

### Running a typical Tutorial

Let's say you wanted to run the very [first tutorial](blog_feed.html), `01_blog_feed`. Here's how you'd do it:

From Bash:

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/javascript/01_blog_feed
npm i
npm run dev-server
```

Then open http://localhost:3000/ in your web browser.

You can also **copy** code from pages here and add into your project for quick tests.

### Github

If you'd rather clone projects in a windowed environment rather than the terminal, consider [Github Desktop](https://desktop.github.com/).
