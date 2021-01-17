//Step 1.

// const dhive = require('@hiveio/dhive');
// //define network parameters
// let opts = {};
// opts.addressPrefix = 'STX';
// opts.chainId = '79276aea5d4877d9a25892eaa01b0adf019d3e5cb12a97478df3298ccdd01673';
// //connect to a hive node, testnet in this case
// const client = new dhive.Client('https://testnet.hive.blog', opts);

const dhive = require('@hiveio/dhive');
let opts = {};
//define network parameters
opts.addressPrefix = 'STM';
opts.chainId =
    'beeab0de00000000000000000000000000000000000000000000000000000000';
//connect to a hive node, production in this case
const client = new dhive.Client('https://api.hive.blog');


//Step 2. user fills in the values on the UI

//Followers function
window.submitFollower = async () => {
    //clear list
    document.getElementById('followList').innerHTML = '';
    
    //get user name
    const username = document.getElementById('username').value;
    //get starting letters / word
    const startFollow = document.getElementById('startFollow').value;
    //get limit
    var limit = document.getElementById('limit').value;

//Step 3. Call followers list

    //get list of followers
    //getFollowers(following, startFollower, followType, limit)
    let followlist = await client.call('follow_api', 'get_followers', [
        username,
        startFollow,
        'blog',
        limit,
    ]);

    document.getElementById('followResultContainer').style.display = 'flex';
    document.getElementById('followResult').className = 'form-control-plaintext alert alert-success';
    document.getElementById('followResult').innerHTML = 'Followers';

//Step 4. Display results on console for control check and on UI
    
    followlist.forEach((newObj) => {
        name = newObj.follower;
        document.getElementById('followList').innerHTML += name + '<br>';
        console.log(name);
    });

};

//Step 2. user fills in the values on the UI

//Following function
window.submitFollowing = async () => {
    //clear list
    document.getElementById('followList').innerHTML = '';
    
    //get user name
    const username = document.getElementById('username').value;
    //get starting letters / word
    const startFollow = document.getElementById('startFollow').value;
    //get limit
    var limit = document.getElementById('limit').value;

//Step 3. Call following list

    //get list of authors you are following
    //getFollowing(follower, startFollowing, followType, limit)
    let followlist = await client.call('follow_api', 'get_following', [
        username,
        startFollow,
        'blog',
        limit,
    ]);

    document.getElementById('followResultContainer').style.display = 'flex';
    document.getElementById('followResult').className = 'form-control-plaintext alert alert-success';
    document.getElementById('followResult').innerHTML = 'Following';

//Step 4. Display results on console for control check and on UI

    followlist.forEach((newObj) => {
        name = newObj.following;
        document.getElementById('followList').innerHTML += name + '<br>';
        console.log(name);
    });
};
