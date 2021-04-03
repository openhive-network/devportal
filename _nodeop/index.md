---
title: Node Operation
section: Node Operation
exclude: true
exclude_in_index: true
canonical_url: .
---
{% assign nav = site.data.nav.toc | where: "collection", "nodeop" | first %}
{% assign col = site.collections | where:"id", nav.collection | first %}
{% assign sorted_docs = col.docs | sort: "position" %}
<section class="row">
  {% if sorted_docs %}
    <ul>
      {% for doc in sorted_docs %}
        {% unless doc.exclude_in_index %}
          <li>
            <a href="{{ doc.id | relative_url }}.html">{{ doc.title }}</a>
            <span class="overview">{{ doc.description | markdownify }}</span>
          </li>
        {% endunless %}
      {% endfor %}
    </ul>
  {% endif %}
</section>
