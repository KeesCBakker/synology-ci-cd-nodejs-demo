# test using the latest node container
FROM node:latest AS ci

# mark it with a label, so we can remove dangling images
LABEL cicd="hello"

WORKDIR /app
COPY package.json .
COPY package-lock.json .
COPY lib ./lib
COPY test ./test
RUN npm ci --development

# test
RUN npm test

# get production modules
RUN rm -rf node_modules && npm ci --production

# This is our runtime container that will end up
# running on the device.
FROM node:alpine

# mark it with a label, so we can remove dangling images
LABEL cicd="hello"

WORKDIR /app
COPY package.json package-lock.json ./

RUN npm ci --production

COPY lib ./lib

# Launch our App.
CMD ["node", "lib/app.js"]