# 之前二期csv都没有header。
# 也就是没有 zh, en。
# 为了统一格式，需要加上。
# 已经使用本脚本处理了。
# 不再需要使用了。

require 'csv'

def ghd(path)
  Dir['path/*.csv'].each do |f|
    c = CSV.read(f).unshift ['en', 'zh']
    out = c.map { |e| e.to_csv(force_quotes: true) }.join('')
    File.write("#{f}.new", out)
  end
end

PATH = 'db/2qi-csv'