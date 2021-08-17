# Synology CI/CD Demo
Builds and deploys a Node.js demo application to your Synology NAS using Git, Docker and Docker-compose.

## What does it do?
If you run `bash run.sh`, it will check if the application is up to date (with Git) and use 
Docker and Docker Compose to spin up the application. When you visit the IP of the machine on 
port 3000, it will return the text `Hello World! My watch says: {server-time}`.

## How does it do it?
<a href="https://keestalkstech.com/2019/11/docker-on-synology-from-git-to-running-container-the-easy-way/">In this blog I show how you can deploy this repository to a Synology NAS.</a>
