FROM node:24.21.0-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY src ./src
# stdio MCP server. Do not publish this container as an unauthenticated public endpoint.
ENTRYPOINT ["node", "src/index.js"]
