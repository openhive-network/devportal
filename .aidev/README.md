# devportal under AIDEV

AIDEV verifies changes through the slots in `project.yaml`, integrates them into
`aidev/integration`, and people merge that into `develop` through merge requests (as in
hive/denser and hive/block_explorer_ui). GitLab CI doesn't run for AIDEV branches; see
`.gitlab-ci.yml` `workflow:`.

## Suites

`.aidev/run-checks.sh <suite> <step>...` writes `test-results/aidev-<suite>/junit.xml`
(one case per step), plus `minitest-junit.xml` and `mcp-junit.xml` with one case per test.

| Step | What |
|---|---|
| `build` | `bundle exec jekyll build` into `_site/` (CI's `build` job) |
| `minitest` | `rake test` (`test/*_test.rb`) against `_site/`; `minitest-junit.rb` turns its `-v` output into junit |
| `mcp` | `node --test` in `mcp/` (CI's `mcp_test` job) |
| `mcp-coverage` | the same with Node's test coverage, lcov in `mcp-lcov.info` |
| `proof` | `rake test:proof:full` (CI's `html_proofer` job): rebuild, html-proofer with external links disabled, the minitest assertions, the hash-anchor check |

| Slot | Steps |
|---|---|
| quick, baseline | build, minitest, mcp |
| full, canary | build, minitest, mcp, proof |
| static, system | proof |
| coverage | mcp-coverage |

Not bound: `rake test:curl` and `scrape:api_defs` call a live Hive node, and the suites run
with `--network none`. There's no Ruby coverage tool in the Gemfile.

## The test runtime image (`runtime/`)

The suites run in a container with `--network none` and your uid. It carries Ruby 3.1.6 with
bundler 2.3.19 and the gems of `Gemfile.lock` (as CI's `ruby:3.1.6` jobs), Node 24.21.0 (as CI's
`mcp_test` job) and an npm cache from `mcp/package-lock.json`. `npm-deps.sh` installs
`mcp/node_modules` offline from it.

When `Gemfile`, `Gemfile.lock`, `mcp/package.json`, `mcp/package-lock.json` or
`runtime/Dockerfile` change, rebuild and re-pin **in the same commit**:

```bash
.aidev/runtime/build.sh --push   # put the printed repo@sha256:<digest> in project.yaml environment.image
```
