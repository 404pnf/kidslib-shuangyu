require 'find'
require 'csv'
require 'erubis'
require 'pp'
require 'fileutils'

CSV_FILEFODLER = 'db/2qi-tsv-csv/'
OUTPUT = 'output-html'
VIEW_FOLDER = 'views'
TPL_FILE = 'views/book.erubis.html'
BOOK_TITLES = 'db/xin-book-titles.csv'

files = Find.find(CSV_FILEFODLER).select { |f| f =~ /csv$/}
titles = CSV.readlines(BOOK_TITLES).reduce(Hash.new) do |h, arr| 
  id, *title = arr
  h[id] = title
  #h[arr[0].to_s] = [arr[1], arr[2]]
  h
end
#pp titles
files.each do |file|
  id = File.basename(file, '.csv')
  title = titles[id].join(' | ') unless titles[id].nil?
  paragraphs = CSV.readlines file
  eruby = Erubis::Eruby.new(File.read(TPL_FILE)) # create Eruby object
  html_str =  eruby.result(binding())   # TODO get result; all local variables are available in the template, might not be a good idea  
  
  # same old file writing
  p "generating #{OUTPUT}/#{id}.html: #{title}"
  File.open("#{OUTPUT}/#{id}.html", "w") do |f|
    f.puts html_str
  end
  
end

# copy necessary js/css files from views/ to output-html
# ref: http://www.ruby-doc.org/stdlib-2.0/libdoc/fileutils/rdoc/FileUtils.html#method-c-copy
FileUtils.cp_r Dir.glob("#{VIEW_FOLDER}/*.js"), OUTPUT, :noop => false, :verbose => true
FileUtils.cp_r Dir.glob("#{VIEW_FOLDER}/*.css"), OUTPUT, :noop => false, :verbose => true

# 友情提示
p ''
p '------------'
p '友情提示'
p '-------------'
p ''
p "生成的文件在： #{OUTPUT}"