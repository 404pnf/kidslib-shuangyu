require 'csv'
require 'pp'
#require 'pstore'
require 'erubis'

input = ARGV[0]

# we need this gsub
# or we get `block (2 levels) in shift': Missing or stray quote in line XXXX (CSV::MalformedCSVError)
# ref: http://stackoverflow.com/questions/14534522/ruby-csv-parsing-string-with-escaped-quotes
# 173,"Yukihiro \"The Ruby Guy\" Matsumoto","Japan"
# The \" is typical Unix whereas Ruby CSV expects ""

c = CSV.parse(File.read(input).gsub('\"', '""'))

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
  book_hash[id] << zh 
  book_hash[id] << en
end
pp book_hash["188"] # keys are STRING representation of number

# generate html of individual book
book_hash.each do |bookid, content|
  title = bookid
  paragraphs = content.each_slice(2).map {|e| e}
  # here comes erubis
  eruby = Erubis::Eruby.new(File.read('book.tpl.erubis.html'))       # create Eruby object
  html_str =  eruby.result(binding())   # TODO get result; all local variables are available in the template, might not be a good idea  
  # same old file writing
  p "generating #{title}.html"
  File.open("#{title}.html", "w") do |file|
    file.puts html_str
  end
end



  







  
  