import { Client, PrivateKey } from '@hiveio/dhive';
import { Mainnet as NetConfig } from '../../configuration'; //A Hive Testnet. Replace 'Testnet' with 'Mainnet' to connect to the main Hive blockchain.

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
    const hive_balance = _account[0].balance;
    const balance = `Available Hive balance for ${name}: ${hive_balance}<br/>`;
    document.getElementById('accBalance').innerHTML = balance;
    document.getElementById('hive').value = hive_balance;
    const receiver = document.getElementById('receiver').value;

    document.getElementById('sc').style.display = 'block';
    const link = `https://hivesigner.com/sign/transfer-to-vesting?from=${name}&to=${receiver}&amount=${hive_balance}`;
    document.getElementById('sc').innerHTML = `<br/><a href=${encodeURI(
        link
    )} target="_blank">Hive Signer signing</a>`;
};

window.submitTx = async () => {
    const privateKey = PrivateKey.fromString(
        document.getElementById('wif').value
    );
    const op = [
        'transfer_to_vesting',
        {
            from: document.getElementById('username').value,
            to: document.getElementById('receiver').value,
            amount: document.getElementById('hive').value,
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
