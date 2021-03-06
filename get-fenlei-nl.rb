require 'csv'

# 命名空间
module Kidslib

  def self.r(f)
    title = CSV.table(f)[0]
    file_id = File.basename(f).sub(/.csv$/, '')
    [title[:zh], title[:en], file_id]
  end

  def self.nianling
    rand(2) == 1 ? '7-9岁' : '10-12岁'
  end

  def self.to_csv_str(arr)
    arr.each_with_object('') { |e, o| o << e.to_csv(force_quotes: true) }
  end

  def get_fenlei_nianling(path)
    a = Dir["#{ path.chomp('/') }/*.csv"].map { |e| r(e) + [nianling] }
    aa = a.map { |zh, en, id, nianling| [id, nianling, '双语阅读', zh, en] }
    aa.unshift %w(id age category title_zh title_en)
    s = to_csv_str aa.sort_by { |id, _, _, _, _| id.to_i }
    p '生成的文件是  ./fenlei.csv'
    File.write('fenlei.csv', s)
  end

  module_function :get_fenlei_nianling

end

Kidslib.get_fenlei_nianling('db/all-csv') if __FILE__ == $PROGRAM_NAME
