# Converts `rake test TESTOPTS=-v` output (minitest 5) to junit: one case per
# test, its failure body the matching "N) Failure:/Error:" block of the report.
#   ruby .aidev/minitest-junit.rb <log> <junit.xml>
require 'cgi'

log_path, junit_path = ARGV
log = File.read(log_path, encoding: 'UTF-8').scrub.gsub(/\e\[[0-9;]*[A-Za-z]/, '')
esc = ->(s) { CGI.escapeHTML(s.to_s).gsub(/[\x00-\x08\x0b\x0c\x0e-\x1f]/, '') }

details = {}
log.split(/^\s*\d+\) (?=(?:Failure|Error|Skipped):\n)/).drop(1).each do |block|
  kind, header, *rest = block.lines
  name = header.to_s[/\A(\S+#\S+?)(?: \[|:$)/, 1] or next
  text = ([header] + rest).join.split(/\n\n\d+ runs, /).first.strip
  details[name] = { kind: kind.strip.chomp(":"), text: text }
end

cases = log.scan(/^(\S+)#(\S+) = ([\d.]+) s = ([.FES])$/).map do |klass, test, time, mark|
  d = details["#{klass}##{test}"]
  body = case mark
         when 'F' then %(<failure message="#{esc[d ? d[:text].lines[1].to_s.strip : 'failed']}">#{esc[d && d[:text]]}</failure>)
         when 'E' then %(<error message="#{esc[d ? d[:text].lines[1].to_s.strip : 'error']}">#{esc[d && d[:text]]}</error>)
         when 'S' then '<skipped/>'
         end
  [mark, %(<testcase classname="#{esc[klass]}" name="#{esc[test]}" time="#{time}">#{body}</testcase>)]
end

count = ->(m) { cases.count { |c| c[0] == m } }
File.write(junit_path, <<~XML)
  <?xml version="1.0" encoding="UTF-8"?>
  <testsuite name="minitest" tests="#{cases.size}" failures="#{count['F']}" errors="#{count['E']}" skipped="#{count['S']}">
  #{cases.map(&:last).join("\n")}
  </testsuite>
XML
warn "junit: #{junit_path}: #{cases.size} minitest cases"
