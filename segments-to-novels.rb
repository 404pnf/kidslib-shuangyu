require 'csv'
require 'pp'
#require 'pstore'
require 'erubis'
require 'fileutils'
require 'kramdown'

INPUT = './db/book_segments.csv'
BOOK_TITLES = './db/book_titles.csv'
OUTPUT = './output-html'
VIEW_FOLDER = 'views'
TPL_FN = 'book.erubis.html'
TPL_FILE =  "#{VIEW_FOLDER}/#{TPL_FN}"

# we need this gsub
# or else: we get `block (2 levels) in shift': Missing or stray quote in line XXXX (CSV::MalformedCSVError)
# ref: http://stackoverflow.com/questions/14534522/ruby-csv-parsing-string-with-escaped-quotes
# if original csv is
# 173,"Yukihiro \"The Ruby Guy\" Matsumoto","Japan"
# The \" is typical Unix whereas Ruby CSV expects ""
c = CSV.parse(File.read(INPUT).gsub('\"', '""'))

zh_en_bookid_tuple = c.map do |r|
  _, _, zh, en, _, _, id, _ = r
  [zh, en, id]
end
#pp zh_en_bookid_tuple[42]

book_hash = Hash.new{ |hash,key| hash[key] = Array.new }
zh_en_bookid_tuple.each do |tuple|
  # NB: id is string, therefore
  # id is "42" but not 42
  # 每本书对应的值是数组，按顺序一段中文一段英文
  zh, en, id = tuple
  book_hash[id] << [zh, en] 
end
#pp book_hash["178"][2][1] # keys are STRING representation of number

# get book titles
book_title_arr = CSV.parse(File.read(BOOK_TITLES).gsub('\"', '""'))
book_title_hash = {}
book_title_arr.each do |(id, zh_title, en_title)|
  book_title_hash[id] = [zh_title, en_title]
end

# generate html of individual book
book_hash.each do |bookid, paragraphs|
  id = bookid
  title_arr = book_title_hash["#{bookid}"]
  title = title_arr.join("<br>") unless title_arr.nil?
  p title
  # here comes erubis
  eruby = Erubis::Eruby.new(File.read(TPL_FILE)) # create Eruby object
  html_str =  eruby.result(binding())   # TODO get result; all local variables are available in the template, might not be a good idea  
  # same old file writing
  p "generating #{OUTPUT}/#{id}.html"
  #p "go checkout #{OUTPUT}"
  File.open("#{OUTPUT}/#{id}.html", "w") do |file|
    file.puts html_str
  end
end

# copy necessary js/css files from views/ to output-html
# ref: http://www.ruby-doc.org/stdlib-2.0/libdoc/fileutils/rdoc/FileUtils.html#method-c-copy
FileUtils.cp_r Dir.glob("#{VIEW_FOLDER}/*.js"), OUTPUT, :noop => true, :verbose => true
FileUtils.cp_r Dir.glob("#{VIEW_FOLDER}/*.css"), OUTPUT, :noop => true, :verbose => true
