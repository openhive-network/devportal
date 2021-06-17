import { Client, PrivateKey } from '@hiveio/dhive';
import { TestnetHive as NetConfig } from '../../configuration'; //A Hive Testnet. Replace 'Testnet' with 'Mainnet' to connect to the main Hive blockchain.

let opts = { ...NetConfig.net };
//connect to a hive node, testnet in this case
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
    document.getElementById('hive').value = vestHive;

    document.getElementById('sc').style.display = 'block';
    const link = `https://testnet.hivesigner.com/sign/withdraw-vesting?account=${name}&vesting_shares=${avail}`;
    document.getElementById('sc').innerHTML = `<br/><a href=${encodeURI(
        link
    )} target="_blank">Hive Signer signing</a>`;
};

window.submitTx = async () => {
    const props = await client.database.getDynamicGlobalProperties();
    const vests = parseFloat(document.getElementById('hive').value) /
      (parseFloat(props.total_vesting_fund_hive) / parseFloat(props.total_vesting_shares));
    const privateKey = PrivateKey.fromString(
        document.getElementById('wif').value
    );
    const op = [
        'withdraw_vesting',
        {
            account: document.getElementById('username').value,
            vesting_shares: vests.toFixed(6) + ' VESTS',
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
