# NodeHashToRedisRemote (c) Alisson Sol

A small web service that hashes a string value and saves to remote Redis the key, value pair. 

# Running

First, complete installation
```bash
npm install
npm install body-parser
npm install express-generator -g
```

Then, configure and test the connection to remote Redis server.
```bash
export REDIS_HOST='192.168.1.1'
export REDIS_PORT=6379
redis-cli -h $REDIS_HOST -p $REDIS_PORT ping
```

Start NodeJS from the working diretory.
```bash
node bin/www
Server up
```

# Installing NodeJS in Amazon Linux

Instruction available in page [Tutorial: Setting Up Node.js on an Amazon EC2 Instance](https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html)

For step 4, instead of installing an old version, using nvm ls-remote to check for available version