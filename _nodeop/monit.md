---
title: Managing a Node Using Monit
position: 6
description: |
  Use monit as a utility for managing and monitoring hived.
exclude: true
layout: full
canonical_url: monit.html
---

### Intro

Monit can restart hived if it crashes, if it does not respond, or stop the process if it uses too many resources.  You can use monit to monitor files, directories and filesystems for changes, such as timestamps changes, checksum changes or size changes.

One of the major benefits of monit is the ability to have hived start when the system restarts.  And if monit is properly configured, you can have your system stop hived when the system shuts down.

### Sections

* [Install Monit](#install-monit)
* [Configure Monit](#configure-monit)

### Install Monit

On linux:

```bash
$ sudo apt-get install monit​
```

For other OS types, refer to: [mmonit.com/monit](https://mmonit.com/monit/)

### Configure Monit

Create file `/home/YOUR_USERNAME/hive_data/start_hived.sh`

```bash
#!/bin/bash

t=`cat /proc/uptime | cut -f 1 -d '.'`
s=30

if [ "$t" -lt "$s" ]; then
  sleep $s
fi

cd /home/YOUR_USERNAME/hive_data
/bin/su YOUR_USERNAME -c "nohup /usr/bin/hived --data-dir=. > hived.log 2>&1 & echo \$! > nohup_hived.pid"
```

We check uptime because if hived starts too soon, p2p may not be available within the first few seconds of OS start.  If hived starts in this state, it will freeze.

Note, we're using nohup to get the pid.  But you can also configure monit to work without it by looking for hived using a matching pattern.  But it's always better to execute a script rather than hived directly.

Create file `/home/YOUR_USERNAME/hive_data/stop_hived.sh`

```bash
#!/bin/bash

cd "/home/YOUR_USERNAME/hive_data"
/bin/su YOUR_USERNAME -c "/bin/kill `/bin/cat nohup_hived.pid`"
```

Make them executable:

```bash
$ chmod +x start_hived.sh​
$ chmod +x stop_hived.sh​
```

Edit the file `/etc/monit/monitrc`:

```bash
$ sudo nano /etc/monit/monitrc​
```

Edit the file as follows:

```
# uncomment these lines
set httpd port 2812 and
use address localhost # only accept connection from localhost
allow localhost # allow localhost to connect to the server
```

Add this to bottom of `/etc/monit/monitrc` (make sure to change YOUR_USERNAME to your username):

```
check process hived with pidfile /home/YOUR_USERNAME/hive_data/nohup_hived.pid
start program = "/home/YOUR_USERNAME/hive_data/start_hived.sh"
  with timeout 60 seconds
stop program = "/home/YOUR_USERNAME/hive_data/stop_hived.sh"
  with timeout 120 seconds
```

Test the new configuration:

```
$ sudo monit -t
```

If it looks ok, then proceed to ...

Load the new configuration:

```
$ sudo monit reload​
```

Enable the watchdog:

```
$ sudo monit start hived​
```

That's it.  You only have to do the above command once.

You can check monit's status by typing below:

```
$ sudo monit status​
```
Or, for a summary view:

```
$ sudo monit summary
```

Which will return something like:

```
Monit 5.26.0 uptime: 52d 2h 55m
┌─────────────────────────────────┬────────────────────────────┬───────────────┐
│ Service Name                    │ Status                     │ Type          │
├─────────────────────────────────┼────────────────────────────┼───────────────┤
│ calculon                        │ OK                         │ System        │
├─────────────────────────────────┼────────────────────────────┼───────────────┤
│ hived                           │ OK                         │ Process       │
└─────────────────────────────────┴────────────────────────────┴───────────────┘
```

This will keep your hived running for you (across restarts, even, no need for any cronjobs or multiplexors) and keep you from fighting with your chosen OS.  Keep in mind, the default is for monit to only once a minute, so be patient if you're waiting for it to do something.
