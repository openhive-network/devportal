import { Client, PrivateKey } from 'dsteem';
import { Mainnet as NetConfig } from '../../configuration'; //A Hive Testnet. Replace 'Testnet' with 'Mainnet' to connect to the main Hive blockchain.

let opts = { ...NetConfig.net };
//connect to a steem node, testnet in this case
const client = new Client(NetConfig.url, opts);

//submitAcc function from html input
const max = 5;
window.submitAcc = async () => {
    const accSearch = document.getElementById('username').value;

    const _account = await client.database.call('get_accounts', [[accSearch]]);
    console.log(`_account:`, _account);

    const name = _account[0].name;
    const avail =
        parseFloat(_account[0].vesting_shares) -
        (parseFloat(_account[0].to_withdraw) -
            parseFloat(_account[0].withdrawn)) /
            1e6 -
        parseFloat(_account[0].delegated_vesting_shares);

    const props = await client.database.getDynamicGlobalProperties();
    const vestHive = parseFloat(
        parseFloat(props.total_vesting_fund_hive) *
            (parseFloat(avail) / parseFloat(props.total_vesting_shares)),
        6
    );

    const balance = `Available Vests for ${name}: ${avail} VESTS ~ ${vestHive} HIVE POWER<br/><br/>`;
    document.getElementById('accBalance').innerHTML = balance;
    document.getElementById('steem').value =
        Number(avail).toFixed(6) + ' VESTS';
};
window.openSC = async () => {
    const link = `https://steemconnect.com/sign/delegate-vesting-shares?delegator=${
        document.getElementById('username').value
    }&vesting_shares=${document.getElementById('steem').value}&delegatee=${
        document.getElementById('account').value
    }`;
    window.open(link);
};
window.submitTx = async () => {
    const privateKey = PrivateKey.fromString(
        document.getElementById('wif').value
    );
    const op = [
        'delegate_vesting_shares',
        {
            delegator: document.getElementById('username').value,
            delegatee: document.getElementById('account').value,
            vesting_shares: document.getElementById('steem').value,
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
