---
title: Hive Nodes
position: 2
exclude: true
---

Applications that interface directly with the Hive blockchain will need to connect to a `hived` node. Developers may choose to use one of the public API nodes that are available, or run their own instance of a node.

### Public Nodes

Although `hived` fully supports WebSockets (`wss://` and `ws://`) public nodes typically do not.  All nodes listed use HTTPS (`https://`).  If you require WebSockets for your solutions, please consider setting up your own `hived` node or proxy WebSockets to HTTPS using [lineman](https://gitlab.syncad.com/hive/lineman).

<div id="report">
  <table>
    <thead>
      <tr><th>URL</th><th>Owner</th><th style="display: none;"></th></tr>
    </thead>
    <tbody>
      <tr><td>api.hive.blog</td><td>@blocktrades</td><td style="display: none;"></td></tr>
      <tr><td>api.openhive.network</td><td>@gtg</td><td style="display: none;"></td></tr>
      <tr><td>anyx.io</td><td>@anyx</td><td style="display: none;"></td></tr>
      <tr><td>rpc.ausbit.dev</td><td>@ausbitbank</td><td style="display: none;"></td></tr>
      <tr><td>rpc.mahdiyari.info</td><td>@mahdiyari</td><td style="display: none;"></td></tr>
      <tr><td>api.hive.blue</td><td>@guiltyparties</td><td style="display: none;"></td></tr>
      <tr><td>techcoderx.com</td><td>@techcoderx</td><td style="display: none;"></td></tr>
      <tr><td>hive.roelandp.nl</td><td>@roelandp</td><td style="display: none;"></td></tr>
      <tr><td>hived.emre.sh</td><td>@emrebeyler</td><td style="display: none;"></td></tr>
      <tr><td>api.deathwing.me</td><td>@deathwing</td><td style="display: none;"></td></tr>
      <tr><td>api.c0ff33a.uk</td><td>@c0ff33a</td><td style="display: none;"></td></tr>
      <tr><td>hive-api.arcange.eu</td><td>@arcange</td><td style="display: none;"></td></tr>
      <tr><td>hive-api.3speak.tv</td><td>@threespeak</td><td style="display: none;"></td></tr>
      <tr><td>hiveapi.actifit.io</td><td>@actifit</td><td style="display: none;"></td></tr>
    </tbody>
  </table>
</div>

<div id="untracked_report"></div>

<script>
  $(document).ready(function() {
    $.ajax({
        url: "https://beacon.peakd.com/api/nodes"
    }).then(function(data) {
      var reportRows = $('#report > table > tbody > tr');
      var tracked = [];
      jQuery.each(reportRows, function(i, row) {
        jQuery.each(data, function(j, r) {
          var host = $(row).find('td:nth-child(1)').text();
          
          if ( r.name.indexOf(host) != -1 && !tracked.includes(j) ) {
            tracked.push(j);
          }
            
          with ( $(row).find('td:nth-child(3)') ) {
            if ( r.name.indexOf(host) != -1 ) {
                if (r.score == 0) {
                    html('Failing ⛔');
                } else {
                    html('Version: <code>' + r.version + '</code> ' + (r.score==100 ? '✅' : '<span title="'+r.score+'%">⚠️</span'));
                }
            }
            show();
          }
        });
      });
      
      with ( $('#report > table > thead > tr > th:nth-child(3)') ) {
        text('Details');
        show();
      }
      
      with ( $('#untracked_report') ) {
        empty();
        
        if ( tracked.length != data.length ) {
          append("<p>Also see the following public nodes:</p><ul>");
          
          jQuery.each(data, function(i, r) {
            if (!tracked.includes(i) ) {
              var host = r.name;
              
              if ( !!host && host.length > 0 ) {
                append('<li>' + host + ', version: <code>' + r.version + '</code> ' + (r.score==100 ? '✅' : '<span title="'+r.score+'%">⚠️</span>') + '</li>');
              }
            }
          });
          
          append("</ul><p>&nbsp;</p>");
        }
      }
    });
  });

</script>

### Private Nodes

The simplest way to get started is by deploying a pre-built dockerized container.

##### Dockerized p2p Node

To install a witness or seed node:

```bash
git clone https://github.com/someguy123/hive-docker.git
cd hive-docker
# If you don't already have a docker installation, this will install it for you
./run.sh install_docker

# This downloads/updates the low-memory docker image for Hive
./run.sh install

# If you are a witness, you need to adjust the configuration as needed
# e.g. witness name, private key, logging config, turn off p2p-endpoint etc.
# If you're running a seed, then don't worry about the config, it will just work
nano data/witness_node_data_dir/config.ini

# (optional) Setting the .env file up (see the env settings section of this readme)
# will help you to adjust settings for hive-in-a-box
nano .env

# Once you've configured your server, it's recommended to download the block log, as replays can be
# faster than p2p download
./run.sh dlblocks

# You'll also want to set the shared memory size (use sudo if not logged in as root). 
# Adjust 64G to whatever size is needed for your type of server and make sure to leave growth room.
# Please be aware that the shared memory size changes constantly. Ask in a witness chatroom if you're unsure.
./run.sh shm_size 64G

# Then after you've downloaded the blockchain, you can start hived in replay mode
./run.sh replay
# If you DON'T want to replay, use "start" instead
./run.sh start
```

You may want to persist the /dev/shm size (shared memory) across reboots. To do this, you can edit `/etc/fstab`, please be very careful, as any mistakes in this file will cause your system to become unbootable.

##### Dockerized Full Node

To install a full RPC node - follow the same steps as above, but use `install_full` instead of `install`.

Remember to adjust the config, you'll need a higher shared memory size (potentially up to 1 TB), and various plugins.

For handling requests to your full node in docker, I recommend spinning up an nginx container, and connecting nginx to the Hive node using a docker network.

Example:

```
docker network create rpc_default
# Assuming your RPC container is called "rpc1" instead of witness/seed
docker network connect rpc_default rpc1
docker network connect rpc_default nginx
```

Nginx will now be able to access the container RPC1 via `http://rpc1:8090` (assuming 8090 is the RPC port in your config). Then you can set up SSL and container port forwarding as needed for nginx.

##### Customized Docker Node

If the above options do not meet your needs, refer to Hive-in-a-box by [@someguy123](https://hive.blog/@someguy123):

[https://github.com/someguy123/hive-docker](https://github.com/someguy123/hive-docker)

##### Building Without Docker

Full non-docker steps can be reviewed here:

[Build Eclipse](https://peakd.com/hive-160391/@gtg/witness-update-release-candidate-for-eclipse-is-out#build-eclipse) by [@gtg](https://hive.blog/@gtg)

### Syncing blockchain

Normally syncing blockchain starts from very first, `0` genesis block.  It might take long time to catch up with live network, because it connects to various p2p nodes in the Hive network and requests blocks from 0 to head block.  It stores blocks in block log file and builds up the current state in the shared memory file.  But there is a way to bootstrap syncing by using trusted `block_log` file.  The block log is an external append only log of the blocks.  It contains blocks that are only added to the log after they are irreversible because the log is append only.

Trusted block log file helps to download blocks faster. Various operators provide public block log file which can be downloaded from:

* [https://files.privex.io/hive/](https://files.privex.io/hive/)
* [https://gtg.openhive.network/get/blockchain/block_log](https://gtg.openhive.network/get/blockchain/block_log)

Both `block_log` files updated periodically, as of March 2021 uncompressed `block_log` file size ~350 GB. (Docker container on `stable` branch of Hive source code has option to use `USE_PUBLIC_BLOCKLOG=1` to download latest block log and start Hive node with replay.)

Block log should be place in `blockchain` directory below `data_dir` and node should be started with `--replay-blockchain` to ensure block log is valid and continue to sync from the point of snapshot. Replay uses the downloaded block log file to build up the shared memory file up to the highest block stored in that snapshot and then continues with sync up to the head block.

Replay helps to sync blockchain in much faster rate, but as blockchain grows in size replay might also take some time to verify blocks.

There is another [trick which might help]({{ 'https://github.com/steemit/steem/issues/2391' | archived_url }}) with faster sync/replay on smaller equipped servers:

```
while :
do
   dd if=blockchain/block_log iflag=nocache count=0
   sleep 60
done
```

Above bash script drops `block_log` from the OS cache, leaving more memory free for backing the blockchain database. It might also help while running live, but measurement would be needed to determine this.

##### Few other tricks that might help:

For Linux users, virtual memory writes dirty pages of the shared file out to disk more often than is optimal which results in hived being slowed down by redundant IO operations.  These settings are recommended to optimize reindex time.

```
echo    75 | sudo tee /proc/sys/vm/dirty_background_ratio
echo  1000 | sudo tee /proc/sys/vm/dirty_expire_centisecs
echo    80 | sudo tee /proc/sys/vm/dirty_ratio
echo 30000 | sudo tee /proc/sys/vm/dirty_writeback_centisecs
```

Another settings that can be changed in `config.ini` is [`flush-state-interval`]({{ '/nodeop/node-config.html#flush-state-interval' | relative_url }}) - it is to specify a target number of blocks to process before flushing the chain database to disk. This is needed on Linux machines and a value of 100000 is recommended. It is not needed on OS X, but can be used if desired.
