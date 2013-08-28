require 'csv'
require 'pp'
require 'fileutils'


INPUT = './db/sql-csv/book_segments.csv'
BOOK_TITLES = './db/book_titles.csv'
OUTPUT = './db/1qi-csv/'

# we need this gsub
# or else: we get `block (2 levels) in shift': Missing or stray quote in line XXXX (CSV::MalformedCSVError)
# ref: http://stackoverflow.com/questions/14534522/ruby-csv-parsing-string-with-escaped-quotes
# if original csv is
# 173,"Yukihiro \"The Ruby Guy\" Matsumoto","Japan"
# NOTE NOTE NOTE NOTE
# The \" is typical Unix whereas Ruby CSV expects ""

# get book titles
book_title_arr = CSV.parse(File.read(BOOK_TITLES).gsub('\"', '""'))
book_title_hash = {}
book_title_arr.each do |(id, zh_title, en_title)|
  book_title_hash[id] = [zh_title, en_title]
end

# get book contents
c = CSV.parse(File.read(INPUT).gsub('\"', '""'))
zh_en_bookid_tuple = c.map do |r|
  _, _, zh, en, _, _, id, _ = r
  [zh, en, id]
end
#pp zh_en_bookid_tuple[42]

# construct a hash with bookid, title and contents
book_hash = Hash.new{ |hash,key| hash[key] = Array.new }
# 把书名先写在第一行
# 这个不能放在后面的 each 中写，那样会重复很多次书名行
# 第一次实际中用到了hash.merge
book_hash.merge(book_title_hash) 
zh_en_bookid_tuple.each do |tuple|
  
  # NB: id is string, therefore
  # id is "42" but not 42
  # 每本书对应的值是数组，按顺序一段中文一段英文
  zh, en, id = tuple
  book_hash[id] << [zh, en] 
end
#pp book_hash["178"][2][1] # keys are STRING representation of number

# writing out individual csv file
book_hash.each do |bookid, paragraphs|
  id = bookid + '.csv'
  csv = paragraphs.map { |para| para.to_csv(force_quotes: true) }
  p "generating #{bookid}"
  File.write("#{OUTPUT}/#{id}", csv.join('') )
end
