
# ## 使用方法
#
#      ruby script.rb input.csv output.csv
#
# 如果不带参数运行，就执行脚本中写死的默认参数
#
# ----

# ## 依赖库
require 'csv'
require 'pp'
require 'fileutils'
# ----

# ## 获取书名
# CSV的格式是
#
#       id,zh,en
#       "1","一个陌生女人的来信","Letter from an Unknown Woman"
#
# 1. 不要把id对应的数字转为fixnum，要string，因此 converters: nil
# 1. 输入的csv已经处理过了双引号问题，因此这里不用预处理
# 1. 如果某个字段为空，用空字符串来取代nil。这样后面用String类方法时，就不会报错
# 1. 如果csv中有注释行，忽略  skip_lines: /^#/
def get_titles(file)
  c = CSV.table(file, converters: nil).map(&:to_hash)
  c.each_with_object({}) { |e, obj| obj[e[:id]] = [e[:zh] || '', e[:en] || ''] }
end
# ----

# ## 图书内容
#
# csv文件按格式
#
#     "id","chapterid","segment_zh","segment_en","length_zh","length_en","bookid","type","last_modified"
#
# 1. 我们只需要段落的中英文和图书id
# 1. 因为id要作为hash的key用，因此不要吧id转为fixnum
# 1. 每个id对应一个数组，是所有段落的中英文对，每个段落是个小数组
# 1. 由于csv是从mysql中导出的，对引号的escpae char是 \"，需要先替换成ruby期待的 ""
# 1. 预先处理的csv，替换了 \" 因此脚本中不需处理
# 1. 有些行注释掉了 csv默认注释可以用顶头的 # 号
#
# 输出格式是
#
#       [["第1段", "para 1"], ["第2段", "para 2"], ... ]
#
# :skip_lines
# When set to an object responding to match, every line matching
# it is considered a comment and ignored during parsing.
# When set to nil no line is considered a comment.
# If the passed object does not respond to match, ArgumentError is thrown.
#
#
def get_contents(file)
  cnt = CSV.table file, converters: nil
  cnt.each_with_object(Hash.new { |h, k| h[k] = Array.new }) do |e, obj|
    id, zh, en = e[:bookid], e[:segment_zh] || '', e[:segment_en] || ''
    obj[id] << [zh, en]
  end
end
# ----

# ## 合并titles和contents，成为图书完整的信息
#
# 1. 一定要以contents散列的键为准，因为titles的中的键远多余contents。就是说
#    有很多书在题目csv中有但内容csv中没有。我们一定要过滤掉这些书
# 1. 用id作为键。生成所有图书的大hash
# 2. 值是书的内容，为数组形式
# 3. contents和titles合并，将title中的题目放到内容数组的第一位
# 4. 而且增加csv标题 ['zh', 'en'] 到数组最开始
#
# 在合并hash的时候，
# 会有很奇怪的错误。
#
#        `<main>': undefined method `to_csv' for "European Civilization 1648-1945":String (NoMethodError)
#
# **这是应为在segments_csv中都没有对应内容，只在book_titles中有**
#
# ----
#
# ### 具体函数
# 1. cnt_h 代表 contents hash, t_h 代表 tittles hash
# 1. cnt_h 中的键是 t_h 中的键的子集
# 1. 合并后的hash应该只包括cnt_h中键，对应的内容是两个hash内容合并起来
# 1. 提前给合并后hash的每个键对应的值预置['zh', 'en']元素。
# 这是后面csv的headers。这个做法挺巧的。正好每本书都需要这个header
#

def book_merge(cnt_h, t_h)
  cnt_h.keys.each_with_object(Hash.new { |h, k| h[k] = [%w(zh en)] }) do |id, obj|
    obj[id] << t_h[id] # 先把题目写进去
    cnt_h[id].each { |e| obj[id] << e } # 内容本身已经是数组套数组了
  end
end

# ## 可以写死的参数
BOOK_CONTENTS = './db/sql-csv/book_segments.csv'
BOOK_TITLES = './db/book_titles.csv'
OUTPUT = './db/all-csv/'
# ----

# ## 写csv文件
def iyc_2_csv
  titles, contents = get_titles(BOOK_TITLES), get_contents(BOOK_CONTENTS)
  books = book_merge contents, titles
  # pp books['1']
  books.each do |bookid, paragraphs|
    id = bookid + '.csv'
    csv = paragraphs.map { |para| para.to_csv(force_quotes: true) }
    # p "generating #{bookid}"
    File.write("#{OUTPUT}/#{id}", csv.join(''))
  end
end

# ## 干活
iyc_2_csv if __FILE__ == $PROGRAM_NAME

# ----
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
