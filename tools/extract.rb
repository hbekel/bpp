#!/usr/bin/env ruby

# Extract all quoted words from input file and output an array literal
# containing all words quoted for use in a regexp

words = []

File.open(ARGV.shift) do |f|
  f.each_line do |line|
    words << line.scan(/\"(.*?)\"/)
  end
end

words.flatten!

words.select! do |word|
  word =~ /\S/
end

words.map! do |word|
  Regexp.quote(word)
end

puts words.inspect

