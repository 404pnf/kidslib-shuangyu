require 'find'
require 'csv'

# 转二期双语的tsv去csv文件

TSV_CSV_FOLDER = 'db/2qi-tsv-csv'

files = Find.find(TSV_CSV_FOLDER).select {|f| f =~ /tsv$/}
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

p "每篇文章csv生成好了，在#{TSV_CSV_FOLDER}"

