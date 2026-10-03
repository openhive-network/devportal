import assert from "node:assert/strict";
import test from "node:test";
import { htmlToText } from "../src/rpc.js";

test("htmlToText drops script and style blocks with their content, case-insensitively", () => {
  const html = [
    "<p>before</p>",
    "<script>var x = 1 < 2;</script>",
    "<SCRIPT type=\"text/javascript\">alert('upper')</SCRIPT>",
    "<style>body { color: red; }</style>",
    "<Style media=\"print\">.x { display: none; }</sTyLe>",
    "<p>after</p>",
  ].join("\n");
  assert.equal(htmlToText(html), "before after");
});

test("htmlToText replaces tags with spaces so adjacent elements stay separate", () => {
  assert.equal(htmlToText("<li>one</li><li>two</li>"), "one two");
  assert.equal(htmlToText("a<br/>b<br>c"), "a b c");
  assert.equal(htmlToText('<td class="x">cell</td><td>next</td>'), "cell next");
});

test("htmlToText decodes the supported HTML entities", () => {
  assert.equal(
    htmlToText("a&nbsp;b &amp; &lt;tag&gt; it&#39;s it&apos;s &quot;q&quot;"),
    "a b & <tag> it's it's \"q\"",
  );
});

test("htmlToText collapses whitespace and trims the result", () => {
  assert.equal(htmlToText("  \n\t<p>  one \n\n two\t</p>   <p>three</p>\n "), "one two three");
  assert.equal(htmlToText("&nbsp;&nbsp;x&nbsp;&nbsp;"), "x");
  assert.equal(htmlToText("<div></div>"), "");
});

test("htmlToText stringifies non-string input", () => {
  assert.equal(htmlToText(42), "42");
  assert.equal(htmlToText(null), "null");
  assert.equal(htmlToText(undefined), "undefined");
  assert.equal(htmlToText({ toString: () => "<b>obj</b>" }), "obj");
});
