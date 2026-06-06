# Claude Code Project Memory - Hive Developer Portal

## Project Overview

The **Hive Developer Portal** is a comprehensive documentation website for the Hive blockchain. It provides:
- API documentation for all Hive blockchain APIs (20+ API namespaces)
- Developer tutorials in JavaScript, Python, Ruby, and PHP
- Node operation guides
- Layer 2 solutions documentation
- Multi-language support (EN, ES, HI, DE, FR, RU, ZH)

**Live Sites**:
- Production: `developers.hive.io`
- Staging: `developers-staging.hive.io`

## Tech Stack

- **Static Site Generator**: Jekyll 3.1.6+ (Ruby-based)
- **Languages**: Ruby, JavaScript, HTML/Liquid, SCSS, Markdown
- **Key Dependencies**:
  - `jekyll` - Static site generator
  - `hive-ruby` - Hive blockchain Ruby client (for API scraping)
  - `html-proofer` - HTML validation
  - `jekyll-multiple-languages-plugin` - i18n support
  - `jekyll-seo-tag` / `jekyll-sitemap` - SEO
- **Frontend**: jQuery, Lunr.js (search), hive.min.js
- **Hosting**: AWS S3 + CloudFront CDN

## Directory Structure

```
devportal/
├── _config.yml              # Jekyll configuration (collections, plugins, languages)
├── _layouts/                # HTML templates (default, full, hive-post, main-script)
├── _includes/               # Reusable components (sidebar, api-template, structures/)
├── _plugins/                # Custom Jekyll filters (archived_url, keywordify, etc.)
├── _sass/                   # SCSS styles (_main, _mixins, _monokai)
├── _data/                   # YAML data files
│   ├── apidefinitions/      # 20 API definition YAML files
│   ├── objects/             # dgpo.yml, config.yml
│   ├── glossary/            # Blockchain terms
│   └── nav.yml              # Navigation structure
├── lib/scrape/              # API scraping automation (api_definitions_job.rb)
├── _introduction/           # Intro docs (Welcome, Web2/Web3, Workflow)
├── _quickstart/             # Getting started docs
├── _tutorials-javascript/   # 37 JavaScript tutorials
├── _tutorials-python/       # 35 Python tutorials
├── _tutorials-ruby/         # 20 Ruby tutorials
├── _tutorials-php/          # 5 PHP tutorials
├── _tutorials-recipes/      # Practical recipes
├── _services/               # Service documentation
├── _layer2/                 # Layer 2 solutions
├── _nodeop/                 # Node operation guides
├── _glossary/               # Blockchain glossary
├── _testnet/                # Testnet documentation
├── js/                      # Client-side JS (hive.min.js, main.js, search.js)
├── css/                     # Compiled CSS
├── images/                  # Icons and graphics
├── Rakefile                 # Rake tasks (scraping, testing, deployment)
├── Makefile                 # Simple build targets
├── Gemfile                  # Ruby dependencies
└── .gitlab-ci.yml           # CI/CD pipeline
```

## Development Commands

### Setup
```bash
bundle install                              # Install dependencies
make vendor                                 # Alternative: bundle install --path vendor/bundle
```

### Development Server
```bash
bundle exec jekyll serve                    # Serve on localhost:4000
bundle exec jekyll serve --host 0.0.0.0     # Remote access
make serve                                  # Via Makefile (port 8080)
```

### Building
```bash
bundle exec jekyll build                    # Generate _site/
bundle exec jekyll build --destination docs # Production build
```

### Rake Tasks
```bash
bundle exec rake -T                         # List all tasks

# API Definition Management
bundle exec rake scrape:api_defs            # Scrape and sync API definitions
TEST_NODE=https://api.hive.blog bundle exec rake scrape:api_defs

# Testing
bundle exec rake test:curl                  # Test all curl examples
bundle exec rake test:curl["follow_api witness_api"]  # Test specific APIs
bundle exec rake test:proof                 # HTML validation with html-proofer

# Data Dumps
bundle exec rake dgpo_dump                  # Dump DGPO fields
bundle exec rake config_dump                # Dump config keys
bundle exec rake ops_dump[true,false]       # Dump operation types
```

### Make Targets
```bash
make serve      # Jekyll serve on port 8080
make vendor     # Install gems to vendor/bundle
make clean      # Remove _site/
make distclean  # Clean + remove vendor/
```

## Key Files

| File | Purpose |
|------|---------|
| `_config.yml` | Jekyll config - collections, plugins, languages, permalinks |
| `Rakefile` | Automation - API scraping, testing, deployment tasks |
| `Gemfile` | Ruby dependencies |
| `.gitlab-ci.yml` | CI/CD pipeline (build, staging, production) |
| `_data/apidefinitions/*.yml` | API method definitions |
| `_data/nav.yml` | Navigation structure |
| `_layouts/default.html` | Main page template |
| `_includes/api-template.html` | API documentation template |
| `lib/scrape/api_definitions_job.rb` | API scraping automation |

## Coding Conventions

### Markdown/Jekyll
- **Front matter**: YAML headers with `title`, `position`, `type`, `description`
- **Localization**: i18n keys like `titles.web2web3` for multi-language
- **Collections**: Files in `_collection/` directories with `position` for ordering

### API Definition YAML Structure
```yaml
- name: API Name
  description: |
    Multi-line description
  methods:
    - api_method: namespace.method_name
      purpose: |
        What this does
      parameter_json: '{}'
      expected_response_json: '{}'
      curl_examples:
        - '{"jsonrpc":"2.0", ...}'
```

### JavaScript
- jQuery-based with event delegation
- Code viewers use `title` attribute for language labels
- Closure patterns for scope management

### SCSS
- Mobile-first with `@media (max-width: $mobile-break)`
- Rem-based sizing (1rem = 10px via 62.5% font-size)
- Variables for breakpoints and colors

## CI/CD Notes

### Pipeline Stages (.gitlab-ci.yml)
1. **build** (all branches): `bundle exec jekyll build -d public`
2. **deploy_staging** (`develop` branch): Sync to S3 staging bucket
3. **deploy_master** (`master` branch): Sync to S3 + CloudFront invalidation

### Environment Variables
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` - AWS credentials
- `S3_BUCKET_NAME_STAGING`, `S3_BUCKET_NAME_PRODUCTION` - Bucket names
- `DISTRIBUTION_ID` - CloudFront distribution ID
- `TEST_NODE` - API endpoint for scraping/testing

### Runner Tags
- `public-runner-docker` - Docker-based runners

### Branches
- `develop` - Integration branch (staging deployments)
- `master` - Production branch
- Feature branches merged via MR to `develop`

## Testing

### API Testing
```bash
# Test all curl examples against live node
bundle exec rake test:curl

# Test specific APIs
bundle exec rake test:curl["follow_api witness_api"]

# Test against different node
TEST_NODE=https://api.openhive.network bundle exec rake test:curl
```

### HTML Validation
```bash
bundle exec rake test:proof   # html-proofer validation
```

### Archive URL Verification
```bash
VERIFY_ARCHIVED_URLS=true bundle exec jekyll build
```

## Quick Reference

| Action | Command |
|--------|---------|
| Start dev server | `bundle exec jekyll serve` |
| Build site | `bundle exec jekyll build` |
| Test curl examples | `bundle exec rake test:curl` |
| Validate HTML | `bundle exec rake test:proof` |
| Scrape API definitions | `bundle exec rake scrape:api_defs` |
| List all rake tasks | `bundle exec rake -T` |
