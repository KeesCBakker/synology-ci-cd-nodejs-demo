# test using the latest node container
FROM node:latest AS teststep

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

# build production packages with the latest node container
FROM node:latest AS buildstep

# mark it with a label, so we can remove dangling images
LABEL cicd="hello"

# Copy in package.json, install
# and build all node modules
WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm ci --production

# This is our runtime container that will end up
# running on the device.
FROM node:alpine

# mark it with a label, so we can remove dangling images
LABEL cicd="hello"

# Copy our node_modules into our deployable container context.
WORKDIR /app
COPY --from=buildstep /app/node_modules node_modules
COPY lib ./lib

# Launch our App.
CMD ["node", "lib/app.js"]