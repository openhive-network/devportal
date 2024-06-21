---
title: titles.nodes
position: 1
exclude: true
---

Applications that interface directly with the Hive blockchain will need to connect to a `Hive` node. Developers may choose to use one of the public API nodes that are available, or run their own instance of a node.

### Public Nodes

All nodes listed use HTTPS (`https://`).  If you require WebSockets for your solutions, please consider setting up your own `hived` node or proxy WebSockets to HTTPS using [lineman](https://gitlab.syncad.com/hive/lineman).

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

**System Requirements**

We assume the base system will be running at least Ubuntu 22.04 (jammy).  Everything will likely work with later 
versions of Ubuntu. IMPORTANT UPDATE: experiments have shown 20% better API performance when running U23.10, so this 
latter version is recommended over Ubuntu 22 as a hosting OS.

For a mainnet API node, we recommend:

* At least 32GB of memory.  If you have 64GB, it will improve the time it takes to sync from scratch, but
it should make less of a difference if you're starting from a mostly-synced HAF node (i.e.,
restoring a recent ZFS snapshot)
* 4TB of NVMe storage
  * Hive block log & shared memory: 500GB
  * Base HAF database: 3.5T (before 2x lz4 compression)
  * Hivemind database: 0.65T (before 2x lz4 compression)
  * base HAF + Hivemind:  2.14T (compressed)
  * HAF Block Explorer: ~0.2T

#### Running Hive node with Docker

**Install ZFS support**

We strongly recommend running your HAF instance on a ZFS filesystem, and this documentation assumes you will be running 
ZFS. Its compression and snapshot features are particularly useful when running a HAF node.
We intend to publish ZFS snapshots of fully-synced HAF nodes that can downloaded to get a HAF node up & running quickly,
avoiding multi-day replay times.

```
sudo apt install zfsutils-linux
```

**Install Docker**

Follow official guide [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/).

**Create a ZFS pool**

Create your ZFS pool if necessary. HAF requires at least 4TB of space, and 2TB NVMe drives are readily available, 
so we typically construct a pool striping data across several 2TB drives. If you have three or four drives, you will 
get somewhat better read/write performance, and the extra space can come in handy.
To create a pool named "haf-pool" using the first two NVMe drives in your system, use a command like:

```
sudo zpool create haf-pool /dev/nvme0n1 /dev/nvme1n1
```
If you name your ZFS pool something else, configure the name in the environment file, as described in the next section.
Note: By default, ZFS tries to detect your disk's actual sector size, but it often gets it wrong for modern NVMe drives,
which will degrade performance due to having to write the same sector multiple times. If you don't know the actual 
sector size, we recommend forcing the sector size to 8k by specifying 
setting ashift=13 (e.g., zfs create -o ashift=13 haf-pool /dev....)

**Configure your environment**

Clone HAF API Node repository from here [https://github.com/openhive-network/haf_api_node](https://github.com/openhive-network/haf_api_node)
Make a copy of the file .env.example and customize it for your system. This file contains configurable parameters for 
things like directories versions of hived, HAF, and associated tools
The docker compose command will automatically read the file named .env. If you want to keep multiple configurations, 
you can give your environment files different names like .env.dev and .env.prod, then explicitly specify the filename 
when running docker compose: `docker compose --env-file=.env.dev ...`

**Set up ZFS filesystems**

The HAF installation is spread across multiple ZFS datasets, which allows us to set different ZFS options for different
portions of the data. We recommend that most nodes keep the default datasets in order to enable easy sharing of snapshots.

**Initializing from scratch**

If you're starting from scratch, after you've created your zpool and configured its name in the .env file as described 
above, run:
```
sudo ./create_zfs_datasets.sh
```

to create and mount the datasets.
By default, the dataset holding most of the database storage uses zfs compression. The dataset for the blockchain data 
directory (which holds the block_log for hived and the shared_memory.bin file) is not compressed because hived directly 
manages compression of the block_log file.
If you have a LOT of nvme storage (e.g. 6TB+), you can get better API performance at the cost of disk storage by 
disabling ZFS compression on the database dataset, but for most nodes this isn't recommended.

**Assisted startup**

```
./assisted_startup.sh
```

Depending on your environment variables, assisted start up script will quickly bootstrap the process.


#### Building Without Docker

Full non-docker steps can be reviewed here:

[Build Eclipse](https://peakd.com/hive-160391/@gtg/witness-update-release-candidate-for-eclipse-is-out#build-eclipse) by [@gtg](https://hive.blog/@gtg)

### Syncing blockchain

**Initializing from a snapshot**

If you're starting with one of our snapshots, the process of restoring the snapshots will create the correct
datasets with the correct options set.
First, download the snapshot file from: [https://gtg.openhive.network/get/snapshot/](https://gtg.openhive.network/get/snapshot/)
Since these snapshots are huge, it's best to download the snapshot file to a different disk (a magnetic
HDD will be fine for this) that has enough free space for the snapshot first, then restore it to the ZFS pool.
This lets you easily resume the download if your transfer is interrupted.  If you download directly to
the ZFS pool, any interruption would require you to start the download from the beginning.
```
wget -c https://whatever.net/snapshot_filename
```


If the transfer gets interrupted, run the same command again to resume.
Then, to restore the snapshot, run:
```
sudo zfs recv -d -v haf-pool < snapshot_filename
```

**Replay with blocklog**

Normally syncing blockchain starts from very first, `0` genesis block.  It might take long time to catch up with live 
network, because it connects to various p2p nodes in the Hive network and requests blocks from 0 to head block.  
It stores blocks in block log file and builds up the current state in the shared memory file.  But there is a way to 
bootstrap syncing by using trusted `block_log` file.  The block log is an external append only log of the blocks.  
It contains blocks that are only added to the log after they are irreversible because the log is append only.

Trusted block log file helps to download blocks faster. Various operators provide public block log file which can be 
downloaded from:

* [https://files.privex.io/hive/](https://files.privex.io/hive/)
* [https://gtg.openhive.network/get/blockchain/block_log](https://gtg.openhive.network/get/blockchain/block_log)

Both `block_log` files updated periodically, as of March 2021 uncompressed `block_log` file size ~350 GB. 
(Docker container on `stable` branch of Hive source code has option to use `USE_PUBLIC_BLOCKLOG=1` to download latest 
block log and start Hive node with replay.)

Block log should be place in `blockchain` directory below `data_dir` and node should be started with 
`--replay-blockchain` to ensure block log is valid and continue to sync from the point of snapshot. 
Replay uses the downloaded block log file to build up the shared memory file up to the highest block stored in that 
snapshot and then continues with sync up to the head block.

Replay helps to sync blockchain in much faster rate, but as blockchain grows in size replay might also take some time 
to verify blocks.

There is another [trick which might help]({{ 'https://github.com/steemit/steem/issues/2391' | archived_url }}) with 
faster sync/replay on smaller equipped servers:

```
while :
do
   dd if=blockchain/block_log iflag=nocache count=0
   sleep 60
done
```

Above bash script drops `block_log` from the OS cache, leaving more memory free for backing the blockchain database. 
It might also help while running live, but measurement would be needed to determine this.

##### Few other tricks that might help:

For Linux users, virtual memory writes dirty pages of the shared file out to disk more often than is optimal which 
results in hived being slowed down by redundant IO operations.  These settings are recommended to optimize reindex time.

```
echo    75 | sudo tee /proc/sys/vm/dirty_background_ratio
echo  1000 | sudo tee /proc/sys/vm/dirty_expire_centisecs
echo    80 | sudo tee /proc/sys/vm/dirty_ratio
echo 30000 | sudo tee /proc/sys/vm/dirty_writeback_centisecs
```

Another settings that can be changed in `config.ini` is [`flush-state-interval`]({{ '/nodeop/node-config.html#flush-state-interval' | relative_url }}) - it is to specify a target number of blocks to process before flushing the chain database to disk. This is needed on Linux machines and a value of 100000 is recommended. It is not needed on OS X, but can be used if desired.
