require 'csv'
require 'pp'
require 'fileutils'


INPUT = './db/sql-csv/book_segments.csv'
BOOK_TITLES = './db/book_titles.csv'
OUTPUT = './db/all-csv/'

# ## ruby需要csv中的双引号是被双引号扩着而不是用反斜杠
#
# we need this gsub
# or else: we get `block (2 levels) in shift': Missing or stray quote in line XXXX (CSV::MalformedCSVError)
#
# ref: <http://stackoverflow.com/questions/14534522/ruby-csv-parsing-string-with-escaped-quotes>
#
# if original csv is
#
#       173,"Yukihiro \"The Ruby Guy\" Matsumoto","Japan"
#
# The \" is typical Unix whereas Ruby CSV expects ""
#
# ----

# ## 获取书名
# CSV的格式是
#
#       id,zh,en
#       "1","一个陌生女人的来信","Letter from an Unknown Woman"
#
# 1. 不要把id对应的数字转为fixnum，要string
# 1. 输入的csv已经处理过了双引号问题
c = CSV.table(BOOK_TITLES, converters: nil, skip_lines: /^#/).map(&:to_hash)
titles = c.each_with_object({}) { |e, obj| obj[ e[:id] ] = [ e[:zh]||'', e[:en]||'' ] }
# ----

# ## 图书内容
#
# 我们只需要段落的中英文和图书id
#
# :skip_lines
# When set to an object responding to match, every line matching it is considered a comment and ignored during parsing. When set to nil no line is considered a comment. If the passed object does not respond to match, ArgumentError is thrown.
#
cnt = CSV.parse(File.read(INPUT).gsub('\"', '""'))
contents = cnt.map do |r|
  _, _, zh, en, _, _, id, _ = r
  [id, zh||'', en||'']
end
# ----

# ## 生成所有图书的信息
#
# 1. 用id作为键。生成所有图书的大hash
# 2. 值是书的内容，为数组形式
# 3. contents和titles合并，将title中的题目放到内容数组的第一位
# 4. 而且增加csv标题 ['zh', 'en'] 到数组最开始
# 5. 有些书根本没有内容，是个空字符串，csv作为nil处理？
# 在合并hash的时候，
# 会有很奇怪的错误。
#
#        `<main>': undefined method `to_csv' for "European Civilization 1648-1945":String (NoMethodError)
#
# **编号325-452的图书，在segments_csv中都没有对应内容，只在book_titles中有**
all_contents = contents.each_with_object(Hash.new{ |h, k| h[k] = Array.new }) do |(id, zh, en), obj|
  obj[id] << [zh, en]
end

# ## 注意！
# titles有549本书
# 而all_contents才437
# 因此我们应该先把那些没有内容的书从title中去除掉
# p titles.size
# p all_contents.size
books = all_contents.merge(titles) do |key, oldval, newval|
  if all_contents.key? key
    oldval.unshift(newval).unshift(['zh','en'])
  else
    next
  end
end

pp books.size  # 没有if else 判断前 =>550
# ----

# ## 写csv文件
=begin
books.each do |bookid, paragraphs|
  id = bookid + '.csv'
  csv = paragraphs.map { |para| para.to_csv(force_quotes: true) }
  p "generating #{bookid}"
  File.write("#{OUTPUT}/#{id}", csv.join('') )
end
=end
