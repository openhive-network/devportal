const dhive = require('@hiveio/dhive');
let opts = {};
//connect to production server
opts.addressPrefix = 'STM';
opts.chainId =
    'beeab0de00000000000000000000000000000000000000000000000000000000';
//connect to server which is connected to the network/production
const client = new dhive.Client('https://api.hive.blog');

//submitAcc function from html input
const max = 5;
window.submitAcc = async () => {
    const accSearch = document.getElementById('username').value;

    const _accounts = await client.database.call('get_accounts', [[accSearch]]);
    console.log(`_accounts:`, _accounts);
    const name = _accounts[0].name;
    const reward_hive = _accounts[0].reward_hive_balance.split(' ')[0];
    const reward_hbd = _accounts[0].reward_hbd_balance.split(' ')[0];
    const reward_hp = _accounts[0].reward_vesting_hive.split(' ')[0];
    const reward_vests = _accounts[0].reward_vesting_balance.split(' ')[0];
    const unclaimed_balance = `Unclaimed balance for ${name}: ${reward_hive} HIVE, ${reward_hbd} HBD, ${reward_hp} HP = ${reward_vests} VESTS<br/>`;
    document.getElementById('accList').innerHTML = unclaimed_balance;
    document.getElementById('hive').value = reward_hive;
    document.getElementById('hbd').value = reward_hbd;
    document.getElementById('hp').value = reward_vests;

    document.getElementById('hc').style.display = 'block';
    const link = `https://hivesigner.com/sign/claim-reward-balance?account=${name}&reward_hive=${reward_hive}&reward_hbd=${reward_hbd}&reward_vests=${reward_vests}`;
    document.getElementById('hc').innerHTML = `<br/><a href=${link} target="_blank">Hive Signer signing</a>`;
};

window.submitTx = async () => {
    const privateKey = PrivateKey.fromString(
        document.getElementById('wif').value
    );
    const op = [
        'claim_reward_balance',
        {
            account: document.getElementById('username').value,
            reward_hive: document.getElementById('hive').value + ' HIVE',
            reward_hbd: document.getElementById('hbd').value + ' HBD',
            reward_vests: document.getElementById('hp').value + ' VESTS',
        },
    ];
    client.broadcast.sendOperations([op], privateKey).then(
        function(result) {
            document.getElementById('result').style.display = 'block';
            document.getElementById(
                'result'
            ).innerHTML = `<br/><p>Included in block: ${
                result.block_num
            }</p><br/><br/>`;
        },
        function(error) {
            console.error(error);
        }
    );
};
