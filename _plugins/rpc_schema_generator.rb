require 'fileutils'

module Jekyll
  # Writes openrpc.json and openapi.json into the site destination.
  #
  # jekyll-multiple-languages-plugin resets the destination before each
  # language pass, which drops files written from a Generator. Hook after
  # that reset (and after the site is written, in case a later pass cleans again) so the
  # artifacts stay at the site root.
  class RpcSchemaGenerator < Generator
    priority :low
    safe true

    def self.write(site)
      # The languages plugin rewrites site.dest to a locale subdirectory.
      # Publish one copy at the real site root.
      return unless File.expand_path(site.dest) == File.expand_path(site.config['destination'])

      root = site.source
      lib = File.join(root, 'lib')
      $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
      require 'export/rpc_schema'

      docs_url = site.config['url'].to_s
      docs_url = 'https://developers.hive.io' if docs_url.empty?
      Export::RpcSchema.new(
        api_data_path: File.join(root, '_data', 'apidefinitions'),
        docs_url: docs_url
      ).write(site.dest)
    end

    def generate(site)
      self.class.write(site)
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  Jekyll::RpcSchemaGenerator.write(site)
end
