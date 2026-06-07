default: serve

.PHONY: vendor clean distclean

serve: vendor/bundle/.bundle-installed
	bundle exec jekyll serve --port 8080

vendor: vendor/bundle/.bundle-installed

vendor/bundle/.bundle-installed: Gemfile Gemfile.lock
	bundle install --path vendor/bundle
	touch vendor/bundle/.bundle-installed

clean:
	rm -rf _site

distclean: clean
	rm -rf vendor
