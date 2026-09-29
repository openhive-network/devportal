---
title: titles.python
section: titles.python
exclude: true
exclude_in_index: true
canonical_url: .
---
{% assign col = site.collections | where:"id", "tutorials-python" | first %}
{% assign sorted_docs = col.docs | sort: "position" %}
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
