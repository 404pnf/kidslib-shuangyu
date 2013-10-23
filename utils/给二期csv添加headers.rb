# 之前二期csv都没有header。
# 也就是没有 zh, en。
# 为了统一格式，需要加上。
# 已经使用本脚本处理了。
# 不再需要使用了。

require 'csv'
require 'find'

# ghd => get header
def ghd(path)
  Find.find(path).each do |f|
    next unless f =~ /.csv$/
    c = CSV.read(f).unshift %w(en zh)
    out = c.map { |e| e.to_csv(force_quotes: true) }
           .join
    File.write("#{f}.new", out)
  end
end

PATH = 'db/2qi-csv'
