# -*- coding: utf-8 -*-
require 'nokogiri'

target_dir = ARGV[0]
outputs = ""

open('dash.snippets', 'w') do |file|
  Dir.glob("#{target_dir}/**/*.sublime-snippet").each do |f|
    doc = Nokogiri::XML(open(f))
    content = doc.xpath('//snippet/content').inner_text
    file.write(content.gsub(/\$\{\d\:*(.*)?\}/, '__\1__'))
  end
end
