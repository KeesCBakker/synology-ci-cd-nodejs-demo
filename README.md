# synology-ci-cd-nodejs-demo
Builds and deploys a demo Node.js application to your Synology NAS using Docker and Docker-compose.

# What does it do?
If you run `bash run.sh`, it will use Docker and Docker Compose to spin up the application. When you 
visit the IP of the machine on port 3000, it will return `Hello World! My watch says: {server-time}`.
