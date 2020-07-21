# synology-ci-cd-nodejs-demo
Builds and deploys a demo Node.js application to your Synology NAS using Docker and Docker-compose.

## What does it do?
If you run `bash run.sh`, it will use Docker and Docker Compose to spin up the application. When you 
visit the IP of the machine on port 3000, it will return `Hello World! My watch says: {server-time}`.

## How does it do it?
<a href="https://keestalkstech.com/2019/11/docker-on-synology-from-git-to-running-container-the-easy-way/">More at this blog. But it uses a multi stage container that will test & build a production container.</a>
