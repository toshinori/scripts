#!/usr/local/bin/ruby

require 'rubygems'
require 'mini_exiftool'

if ARGV.length == 0 then
  puts 'please input directory.'
  exit
end

target_dir = File::expand_path(ARGV[0])

if !(FileTest.exists?(target_dir) and FileTest.directory?(target_dir)) then
  puts 'please input directory.'
  exit
end

count = 1;

Dir.entries(target_dir).each {|d|
  next if d =~ /^\./
  
  author_name = d
  author_dir = File.join(target_dir, author_name)
  
  next if (!FileTest.directory?(author_dir))
  
  Dir.entries(author_dir).each {|pdf|
    next if pdf =~ /^\./
  
    path = File.join(author_dir, pdf)
    title = File::basename(path, File::extname(path))
    
    pdf_file = MiniExiftool.new(path)
    next if pdf_file['Title'].to_s.length > 0
    
    pdf_file['Title'] = title
    pdf_file['Author'] = author_name
    pdf_file.save
    
    count = count + 1
    }
  
  p count
}
