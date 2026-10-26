# No default: the Node version is common-ci-configuration's NODE_IMAGE_VERSION
# (its CI passes it as this build arg); see README.md for a local build.
ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY src ./src
# stdio MCP server. Do not publish this container as an unauthenticated public endpoint.
ENTRYPOINT ["node", "src/index.js"]
