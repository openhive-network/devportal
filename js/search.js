(function () {
	function getQueryVariable(variable) {
		var query = window.location.search.substring(1),
			vars = query.split("&");

		for (var i = 0; i < vars.length; i++) {
			var pair = vars[i].split("=");

			if (pair[0] === variable) {
				return pair[1];
			}
		}
	}

	// The query is attacker-controlled: it arrives from location.search and is
	// echoed back into the page. Everything derived from it has to be escaped
	// before it goes anywhere near innerHTML.
	function escapeHTML(str) {
		return String(str)
			.replace(/&/g, "&amp;")
			.replace(/</g, "&lt;")
			.replace(/>/g, "&gt;")
			.replace(/"/g, "&quot;")
			.replace(/'/g, "&#39;");
	}

	function escapeRegExp(str) {
		return String(str).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
	}

	function getPreview(query, content, previewLength) {
		previewLength = previewLength || (content.length * 2);

		var parts = query.split(" "),
			match = content.toLowerCase().indexOf(query.toLowerCase()),
			matchLength = query.length,
			preview;

		// Find a relevant location in content
		for (var i = 0; i < parts.length; i++) {
			if (match >= 0) {
				break;
			}

			match = content.toLowerCase().indexOf(parts[i].toLowerCase());
			matchLength = parts[i].length;
		}

		// Create preview
		if (match >= 0) {
			var start = match - (previewLength / 2),
				end = start > 0 ? match + matchLength + (previewLength / 2) : previewLength;

			preview = content.substring(start, end).trim();

			if (start > 0) {
				preview = "..." + preview;
			}

			if (end < content.length) {
				preview = preview + "...";
			}

			// Escape first, then wrap the matches, so the <strong> we add is the
			// only markup that survives into innerHTML.
			preview = escapeHTML(preview);

			var alternates = [];
			for (var j = 0; j < parts.length; j++) {
				if (parts[j]) {
					alternates.push(escapeRegExp(escapeHTML(parts[j])));
				}
			}

			// Highlight query parts
			if (alternates.length) {
				preview = preview.replace(new RegExp("(" + alternates.join("|") + ")", "gi"), "<strong>$1</strong>");
			}
		} else {
			// Use start of content if no match found
			preview = escapeHTML(content.substring(0, previewLength).trim()) + (content.length > previewLength ? "..." : "");
		}

		return preview;
	}

	function displaySearchResults(results, query) {
		var searchResultsEl = document.getElementById("search-results"),
			searchProcessEl = document.getElementById("search-process");

		if (results.length) {
			var resultsHTML = "";
			results.forEach(function (result) {
				var item = window.data[result.ref],
					contentPreview = getPreview(query, item.content, 170),
					titlePreview = getPreview(query, item.title);

				resultsHTML += "<li><h4><a href='.." + escapeHTML(item.url) + "'>" + titlePreview + "</a></h4><p><small>" + contentPreview + "</small></p></li>";
			});

			searchResultsEl.innerHTML = resultsHTML;
			searchProcessEl.innerText = "Showing";
      searchProcessEl.style.backgroundImage = "none";
		} else {
			searchResultsEl.style.display = "none";
			searchProcessEl.innerText = "No";
      searchProcessEl.style.backgroundImage = "none";
		}
	}

	window.index = lunr(function () {
		this.field("id");
		this.field("title", {boost: 10});
		this.field("category");
		this.field("url");
		this.field("content");
		this.field("keywords");
	});

	var rawQuery = (getQueryVariable("q") || "").replace(/\+/g, "%20"),
		query,
		searchQueryContainerEl = document.getElementById("search-query-container"),
		searchQueryEl = document.getElementById("search-query"),
		searchInputEl = document.getElementById("search-input");

	// A malformed percent-escape (e.g. ?q=%E0%A4%A) makes decodeURIComponent throw.
	try {
		query = decodeURIComponent(rawQuery);
	} catch (error) {
		query = rawQuery;
	}

	searchInputEl.value = query;

	// Built as DOM nodes rather than an innerHTML string: the query is untrusted.
	var googleLink = document.createElement("a");
	googleLink.href = "https://www.google.com/search?q=site%3Adevelopers.hive.io+" + encodeURIComponent(query);
	googleLink.textContent = query;

	searchQueryEl.textContent = "";
	searchQueryEl.appendChild(googleLink);
	searchQueryContainerEl.style.display = "inline";

	for (var key in window.data) {
		window.index.add(window.data[key]);
	}

	displaySearchResults(window.index.search(query), query); // Hand the results off to be displayed
})();
