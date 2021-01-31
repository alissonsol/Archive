var express = require('express');
var router = express.Router();
var bodyParser = require('body-parser');
router.use(bodyParser.json());
router.use(bodyParser.urlencoded({ extended: true }));

var port = process.env.REDIS_PORT;
var host = process.env.REDIS_HOST;
var redis = require('redis');
var redisClient = redis.createClient(port,host);

// TODO: More elegant solution than this 'sync' include (and the commenting of the strict in the included file).
var fs = require('fs');
eval(fs.readFileSync('routes/sjcl.js')+'');

router.post('/', function (request, response) {
    var message = request.body.message;
    console.log(message);
    var bitArray = sjcl.hash.sha256.hash(message);
    var digest_sha256 = sjcl.codec.hex.fromBits(bitArray);
    redisClient.set(digest_sha256, message);
    response.status(200).json({ 'digest' : digest_sha256 });
});

router.get('/:hash', function (request, response, next) {
    var hash = request.params.hash;

    redisClient.get(hash, function(err, reply) {
        console.log(reply);
        if (reply != null && reply != "") {
            response.status(200).json({ 'message' : reply });
        }
        else {
            response.status(404).json({ 'err_msg' : 'Message not found' });
        }
    });
});

module.exports = router;
