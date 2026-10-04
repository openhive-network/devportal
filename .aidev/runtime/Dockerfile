# The image AIDEV runs this project's suites in (`environment.image` in
# .aidev/project.yaml). Suites run with `--network none`, so everything they need
# is in the image, matching what .gitlab-ci.yml uses today:
#   - Ruby 3.1.6 (`image: ruby:3.1.6`, .ruby-version) with bundler 2.3.19 and the
#     gems of Gemfile.lock installed system-wide (jekyll, html-proofer, minitest);
#   - Node 24.21.0 (the `mcp_test` job's `node:24.21.0`) and an npm cache filled from
#     mcp/package-lock.json, so `npm ci --offline` can install mcp/node_modules.
# Build and pin it with .aidev/runtime/build.sh; see .aidev/README.md.
FROM node:24.21.0-bookworm-slim@sha256:0e0ff40c39bc087845bfb27465a0df4ea419520094bc35842ff83dd8cbe6f9b6 AS node

FROM ruby:3.1.6-bookworm@sha256:aaf664741b8de45efe7c5db430430784c11af7d069027b2f008b74a53b8882ae

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

ENV LANG=C.UTF-8 \
    BUNDLE_FROZEN=true \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    npm_config_cache=/opt/npm-cache \
    npm_config_update_notifier=false \
    npm_config_fund=false \
    npm_config_audit=false \
    DO_NOT_TRACK=1

COPY Gemfile Gemfile.lock /tmp/gems/
COPY mcp/package.json mcp/package-lock.json /tmp/mcp/
RUN gem install bundler -v "$(tail -1 /tmp/gems/Gemfile.lock | tr -d ' ')" \
    && cd /tmp/gems && bundle install --jobs 4 \
    && cd /tmp/mcp && npm ci --ignore-scripts \
    && cd / && rm -rf /tmp/gems /tmp/mcp /usr/local/bundle/cache \
    && chmod -R a+rwX /opt/npm-cache

# The suites run with the caller's uid, which has no home in the image.
ENV HOME=/tmp
