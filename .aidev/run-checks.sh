#!/usr/bin/env bash
# The checks AIDEV's verification slots run (.aidev/project.yaml), as one junit
# report per suite: each named step is a test case, its log the failure body.
#
#   .aidev/run-checks.sh <suite> <step>...     steps: build minitest mcp proof
#
#   build     `bundle exec jekyll build` into _site/ (CI's build job builds the same
#             site into public/)
#   minitest  `rake test` (test/*_test.rb) against the _site/ that `build` wrote,
#             every test its own junit case in $out/minitest-junit.xml
#   mcp       the mcp/ package's `node --test` suite (CI's mcp_test job), every
#             test its own case in $out/mcp-junit.xml
#   proof     `rake test:proof:full` (CI's html_proofer job): rebuilds the site,
#             runs html-proofer (scripts, links, images; external links disabled),
#             the minitest assertions, and the internal hash-anchor check
#   mcp-coverage  `mcp` with Node's test coverage, lcov in $out/mcp-lcov.info
set -uo pipefail
cd "$(dirname "$0")/.."

suite="${1:?usage: $0 <suite> <step>...}"; shift
out="test-results/aidev-$suite"
rm -rf "$out"; mkdir -p "$out"
cases="$out/cases.tsv"; : > "$cases"
source .aidev/junit-helpers.sh

status=0
step() {
    local name="$1"; shift
    local log="$out/$name.log" t0=$SECONDS rc=0
    echo "== $name" >&2
    "$@" > "$log" 2>&1 < /dev/null || rc=$?
    if [ "$rc" -eq 0 ]; then
        printf 'case\t%s\tpass\t%s\t\n' "$name" "$((SECONDS - t0))" >> "$cases"
    else
        status=1; tail -40 "$log" >&2
        printf 'case\t%s\tfail\t%s\texit %s\t%s\n' "$name" "$((SECONDS - t0))" "$rc" "$log" >> "$cases"
    fi
}

jekyll_build() { bundle exec jekyll build; }

minitest() {
    local rc=0
    [ -d _site ] || jekyll_build || return 1
    SITE_DIR=_site bundle exec rake test TESTOPTS=-v > "$out/minitest.out" 2>&1 || rc=$?
    cat "$out/minitest.out"
    ruby .aidev/minitest-junit.rb "$out/minitest.out" "$out/minitest-junit.xml"
    return "$rc"
}

mcp_tests() {
    # shellcheck source=npm-deps.sh
    source .aidev/npm-deps.sh || return 1
    local junit="$PWD/$out/mcp-junit.xml" extra=()
    [ "${1:-}" = coverage ] && extra=(--experimental-test-coverage
        --test-reporter=lcov --test-reporter-destination="$PWD/$out/mcp-lcov.info")
    (cd mcp && node --test --test-reporter=spec --test-reporter-destination=stdout \
        --test-reporter=junit --test-reporter-destination="$junit" "${extra[@]}" test/*.test.js)
}

for s in "$@"; do
    case "$s" in
        build) step build jekyll_build ;;
        minitest) step minitest minitest ;;
        mcp) step mcp mcp_tests ;;
        mcp-coverage) step mcp-coverage mcp_tests coverage ;;
        proof) step proof bundle exec rake test:proof:full ;;
        *) echo "unknown step: $s" >&2; exit 2 ;;
    esac
done
junit_write_cases "$out/junit.xml" "$suite" "$cases"
exit "$status"
