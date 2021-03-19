---
title: 'RB: Get Post Comments'
position: 7
description: "This example will output the reply details and totals for the post/comment passed as an argument to the script."
layout: full
canonical_url: get_post_comments.html
---
Full, runnable src of [Get Post Comments](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby/07_get_post_comments) can be downloaded as part of: [tutorials/javascript](https://gitlab.syncad.com/hive/devportal/-/tree/master/tutorials/ruby) (or download just this tutorial: [devportal-master-tutorials-ruby-07_get_post_comments.zip](https://gitlab.syncad.com/hive/devportal/-/archive/master/devportal-master.zip?path=tutorials/ruby/07_get_post_comments)).

### Script

[`comments_list.rb`](https://gitlab.syncad.com/hive/devportal/-/blob/master/tutorials/ruby/07_get_post_comments/comments_list.rb)

First, we ask the blockchain for the replies on a post or comment.  Then, we grab the authors of those replies and list them, followed by the total comments count.

### To Run

First, set up your workstation using the steps provided in [Getting Started]({{ '/tutorials-ruby/getting_started' | relative_url }}).  Then you can create and execute the script (or clone from this repository):

```bash
git clone https://gitlab.syncad.com/hive/devportal.git
cd devportal/tutorials/ruby/07_get_post_comments
bundle install
ruby comments_list.rb https://hive.blog/communityfork/@hiveio/announcing-the-launch-of-hive-blockchain
```

### Example Output

```
Replies by:
	berniesanders
	howo
	roelandp
	anomadsoul
	netuoso
	c0ff33a
	florianopolis
	davedickeyyall
	traducciones
	tsnaks
	pwny
	themarkymark
.
.
.
	hr1
	marybellrg
	victor26
	nelsonnils
	fozdru
	scholaris
	thromaspang
	a-alice
	joetunex
	awesomegames007
	jsl416
	retinox
	gringo211985
	rudyardcatling
	knowledges
	mudcat36
	dkkarolien
Total replies: 522
```


---
