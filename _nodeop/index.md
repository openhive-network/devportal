---
title: titles.node_operation
section: titles.node_operation
exclude: true
exclude_in_index: true
canonical_url: .
---
{% assign nav = site.data.nav.toc | where: "collection", "nodeop" | first %}
{% assign col = site.collections | where:"id", nav.collection | first %}
{% assign sorted_docs = col.docs | sort: "position" %}
<section class="row center">
<h3>{% t descriptions.node_setup %}</h3>
<p>{% t descriptions.node_setup_desc %}</p>
</section>
<section class="row">
  {% if sorted_docs %}
    <ul>
      {% for doc in sorted_docs %}
        {% unless doc.exclude_in_index %}
          <li>
            <a href="{{ doc.id | relative_url }}.html">{% t doc.title %}</a>
            {% capture description %}{% t doc.description %}{% endcapture %}
            <span class="overview">{{ description | markdownify }}</span>
          </li>
        {% endunless %}
      {% endfor %}
    </ul>
  {% endif %}
</section>
