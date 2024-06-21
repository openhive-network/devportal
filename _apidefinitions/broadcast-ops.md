---
position: 99
exclude: true
title: titles.broadcast_ops
canonical_url: .#apidefinitions-broadcast-ops
---

Ops:
<ul>
{% for sections in site.data.apidefinitions.broadcast_ops %}
{% assign sorted_ops = sections.ops | sort: 'name' %}
{% for op in sorted_ops %}
{% unless op.virtual %}
<li class="button"><a href="#broadcast_ops_{{ op.name | slug}}">{{op.name | split: '.' | last}}</a></li> 
{% endunless %}
{% endfor %}
{% endfor %}
</ul>

Virtual Ops:
<ul>
{% for sections in site.data.apidefinitions.broadcast_ops %}
{% assign sorted_ops = sections.ops | sort: 'name' %}
{% for op in sorted_ops %}
{% if op.virtual %}
<li class="button"><a href="#broadcast_ops_{{ op.name | slug}}">{{op.name | split: '.' | last}}</a></li>
{% endif %}
{% endfor %}
{% endfor %}
</ul>

{% for sections in site.data.apidefinitions.broadcast_ops %}
{{ sections.description | liquify | markdownify }}
{% for op in sections.ops %}
<ul style="float: right; list-style: none;">
{% if op.since %}
<li class="success"><strong><small>Since: {{op.since}}</small></strong></li>
{% endif %}
{% if op.virtual %}
<li class="info"><strong><small>Virtual Operation</small></strong></li>
{% endif %}
{% if op.deprecated %}
<li class="warning"><strong><small>Deprecated</small></strong></li>
{% endif %}
{% if op.disabled %}
<li class="warning"><strong><small>Disabled</small></strong></li>
{% endif %}
{% if op.client_docs %}
<li class="info"><strong><small>SDK Reference</small></strong>{% for client_doc in op.client_docs %}<small>{{ client_doc | markdownify }}</small>{% endfor %}</li>
{% endif %}
{% assign keywords = op.name | keywordify | escape %}
{% assign search_url = '/search/?q=' | append: keywords | split: '_' | join: ' ' %}
<li class="info"><strong><small><a href="{{ search_url | relative_url }}">Related <i class="fas fa-search fa-xs"></i></a></small></strong></li>
</ul>
<h4 id="broadcast_ops_{{ op.name | slug }}">
<code>{{op.name}}</code>
<a href="#broadcast_ops_{{ op.name | slug}}">
<i class="fas fa-link fa-xs"></i></a>
</h4>
{{ op.purpose | liquify | markdownify }}
<h5 id="{{ op.name | slug }}-roles">Roles: <code>{{op.roles}}</code></h5>
<h5 id="{{ op.name | slug }}-parameter">Parameters: <code>{{op.params}}</code></h5>
{% if op.json_examples %}
<h5 id="{{ op.name | slug }}-json-examples">Example Op:</h5>
{% for json_example in op.json_examples %}
```json
{{json_example | neat_json}}
```
{% endfor %}
{% endif %}
<hr />
{% endfor %}
{% endfor %}
