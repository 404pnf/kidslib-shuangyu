
# # 转二期双语的tsv去csv文件

require 'find'
require 'csv'

TSV_CSV_FOLDER = 'db/2qi-tsv-csv'

# 1. 收集所有tsv文件
# 1. 去掉结尾的换行符
files = Find.find(TSV_CSV_FOLDER).select {|f| f =~ /tsv$/}
contents = files.map { |fn| File.readlines(fn).map { |l| l.chomp } }
# ----

# tsv文件是用 \t 分割的
#
# 将每行转为数组再转为csv
def tsv_2_csv arr
  arr.map { |l| l.split(/\t/).to_csv(force_quotes: true) }
end
# ----

# 1. 将每行的csv合并为一个大字符串
# 1. 文件名和内容对应成tuple
csv_contents = contents.map {|c| tsv_2_csv(c).join}
fn_with_csv_files = files.zip csv_contents
# ----

# 将文件名从xls.tsv转为txt
def new_fn str
  str.sub(/xls.tsv$/, 'txt')
end

# ----
# ## 干活
fn_with_csv_files.each { |fn, content|  File.write(new_fn(fn), content)}

p "文章的csv生成好了，在#{TSV_CSV_FOLDER}"

