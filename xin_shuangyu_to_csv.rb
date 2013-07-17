require 'find'
require 'csv'


path = ARGV[0] 
files = Find.find(path).select {|f| f =~ /tsv$/}
#p files
contents = files.map { |fn| File.readlines(fn).map { |l| l.chomp } }
#p contents[130]

def tsv_2_csv arr
  arr.map { |l| l.split(/\t/).to_csv(force_quotes: true) }
end

csv_contents = contents.map {|c| tsv_2_csv(c).join}
#p csv_contents[130]

fn_with_csv_files = files.zip csv_contents

def new_fn str
  str.sub(/xls.tsv$/, 'txt')
end

fn_with_csv_files.each { |fn, content|  File.write(new_fn(fn), content)}

