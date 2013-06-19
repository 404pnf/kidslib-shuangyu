require 'csv'
require 'pp'
#require 'pstore'
require 'erubis'

INPUT = './db/book_segments.csv'
OUTPUT = './output-html'
TPL_FILE = './book.tpl.erubis.html'

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
  zh, en, id = tuple
  # NB: id is string, therefore
  # id is "42" but not 42
  # 每本书对应的值是数组，按顺序一段中文一段英文
  book_hash[id] << [zh, en] 
end
#pp book_hash["178"][2][1] # keys are STRING representation of number

# generate html of individual book
book_hash.each do |bookid, paragraphs|
  title = bookid
  # here comes erubis
  eruby = Erubis::Eruby.new(File.read(TPL_FILE)) # create Eruby object
  html_str =  eruby.result(binding())   # TODO get result; all local variables are available in the template, might not be a good idea  
  # same old file writing
  #p "generating #{OUTPUT}/#{title}.html"
  p "go checkout #{OUTPUT}"
  File.open("#{OUTPUT}/#{title}.html", "w") do |file|
    file.puts html_str
  end
end



  







  
  