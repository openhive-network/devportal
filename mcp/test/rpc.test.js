import assert from "node:assert/strict";
import test from "node:test";
import { htmlToText } from "../src/rpc.js";

test("htmlToText drops script and style blocks with their content, case-insensitively", () => {
  const html = [
    "<p>before</p>",
    '<script type="text/javascript">var x = "<b>hidden</b>";</script>',
    "<SCRIPT>alert(1)</SCRIPT>",
    "<style>.a { color: red; }</style>",
    "<Style media=\"print\">body{display:none}</sTyLe>",
    "<p>after</p>",
  ].join("");
  assert.equal(htmlToText(html), "before after");
});

test("htmlToText replaces tags with spaces so adjacent elements stay separate", () => {
  assert.equal(htmlToText("<td>one</td><td>two</td>"), "one two");
  assert.equal(htmlToText('<a href="/x">link</a>text<br/>more'), "link text more");
});

test("htmlToText decodes the supported entities", () => {
  assert.equal(htmlToText("a&nbsp;b"), "a b");
  assert.equal(htmlToText("&amp; &lt; &gt; &#39; &apos; &quot;"), "& < > ' ' \"");
  assert.equal(htmlToText("Tom&#39;s &quot;api&quot; &lt;v1&gt;"), "Tom's \"api\" <v1>");
});

test("htmlToText collapses whitespace and trims the result", () => {
  assert.equal(htmlToText("  \n\t<p>  hello \n\n   world </p>\t \r\n"), "hello world");
  assert.equal(htmlToText("<div>&nbsp;&nbsp;x&nbsp;&nbsp;</div>"), "x");
});

test("htmlToText stringifies non-string input", () => {
  assert.equal(htmlToText(42), "42");
  assert.equal(htmlToText(null), "null");
  assert.equal(htmlToText(undefined), "undefined");
  assert.equal(htmlToText({ toString: () => "<b>obj</b>" }), "obj");
});
