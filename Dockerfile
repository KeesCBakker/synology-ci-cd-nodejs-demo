#build using the latest node container
FROM node:latest AS buildstep

# Copy in package.json, install
# and build all node modules
WORKDIR /app
COPY src/package.json .
COPY src/package-lock.json .
RUN npm ci --production

# This is our runtime container that will end up
# running on the device.
FROM node:alpine

WORKDIR /app

# Copy our node_modules into our deployable container context.
COPY --from=buildstep /app/node_modules node_modules
COPY src/app.js .

# Launch our App.
CMD ["node", "app.js"]