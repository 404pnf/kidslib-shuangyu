# # 这个脚本基本没有了
# 只是当时用一回吧
# 先保留着
# ----

require 'csv'

# 1. 转二期双语的信息表文件到csv
# 2. 并生成二期文件的id,中文书名,英文书名csv

BOOK_INFO = 'db/xin-book-info-category.tsv'
BOOK_INFO_CSV = 'db/xin-book-info.csv'
XIN_BOOK_TITLES = 'db/xin-book-titles.csv'
s = File.readlines BOOK_INFO
arr = s.map { |l| l.chomp.split(/\t/) }
csv = arr.map { |l| l.to_csv(force_quotes: true) }
# csv header
# "书名（英文）","书名","fenlei","nianling","bid"
csv_str = csv.join

# 1. 转二期双语的信息表文件到csv
File.write(BOOK_INFO_CSV, csv_str)

xin_book_titles = arr.map { |r| [r[4], r[1], r[0]].to_csv(force_quotes: true) }
# 2. 并生成二期文件的id,中文书名,英文书名csv
p "生成二期书名文件： #{XIN_BOOK_TITLES}"
File.write(XIN_BOOK_TITLES, xin_book_titles.join)
