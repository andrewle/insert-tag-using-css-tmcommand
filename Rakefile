#!/usr/bin/env ruby

desc "Pull the ruby file in lib/ into the tmCommand file"
task :build do
  require 'rexml/document'
  include REXML
  file = "Insert Tag Using CSS Selectors with Current Word.tmCommand"
  xml = Document.new(File.open(file))
  
  contents = IO.read('lib/insert_tag_using_css.rb')
  xml.elements["plist//dict//string[3]"].text = Text.new(contents, true)

  File.open(file, File::TRUNC|File::RDWR) do |f|
    xml.write(f)
  end
end
  
desc "Run tests (the eyeballing kind)"
task :test do
  IO.readlines('test/fixtures.txt').each do |line|
    result = `echo '#{line}' | ruby lib/insert_tag_using_css.rb`
    puts result unless result.empty?
  end
end