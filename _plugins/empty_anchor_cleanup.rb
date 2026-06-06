Jekyll::Hooks.register [:pages, :documents], :post_render do |item|
  next unless item.output_ext == '.html'

  item.output = item.output.gsub(
    %r{<a\s+name=(['"])([^'"]+)\1\s*></a>},
    '<span id="\2"></span>'
  )
end
