---
title: titles.chain_basics
position: 1
description: Dictionary of Chain Basic Terms
canonical_url: chain_basics.html
---

<table>
	<tr>
		<th>Term</th><th>Definition</th>
	</tr>
{% for term in site.data.glossary.blockchain %}
	<tr>
		<td>{{ term.term }}</td><td>{{ term.definition }}</td>
	</tr>
{% endfor %}
</table>
