
# ## 使用方法
#
#     ruby script.rb inputdir, outputdir
#
# ----

# ## 脚本说明
#
# 将csv文件的记录变成html。html中通过标签配合js达到了中英文分栏显示
# 且可以单独看中文或英文
#
# csv文件格式是
#
#     zh, en
#     "中文第1段", "para 1"
#     "中文第2段", "para 2"
#
# ----

# ## 模版文件
#
# 参考 views/book.erubis.html
#
# ----

# ## 引用库
require 'csv'
require 'erubis'
require 'fileutils'


# ## 类只是为了封装
# 只是为了封装
class Bilingual

  # 如果不用File.basename @id返回的是带着input path的路径
  # 后面写文件到out的时候，不需要这个路径
  def initialize(file)
    @h = CSV.table(file).map(&:to_hash) # an array of hash
    @id = File.basename(file).sub(/\.csv$/, '')
  end

  def context
    t, *content = @h # 第一行是题目
    title = [t[:zh]||'', t[:en]||''].join(' | ')
    {
        title: title,
        content: content,
    }
  end

  def id
    @id
  end

  def title
    self.context[:title]
  end

end

# ----
# ## 绑定变量到模版的并写文件的函数
def xin_csv_2_html(input, out)
  files = Dir["#{input}/*.csv"]

  files.each do |file|
    e = Bilingual.new file

    eruby = Erubis::Eruby.new(File.read(TPL_FILE))
    html_str =  eruby.evaluate(e.context)

    p "generating #{out}/#{e.id}.html: #{e.title}"
    File.write("#{out}/#{e.id}.html", html_str)
  end
end

# ---
# ## 复制样式等资源文件到输出目录
def copy_asset_to_output
  FileUtils.cp_r 'views/.', 'output', :verbose => true
end

# ----
# ## 预设常量
CSV_FILEFODLER =  'db/all-csv/'
OUTPUT = 'output'
VIEW_FOLDER = 'views'
TPL_FILE = 'views/book.erubis.html'
SUFFIX = '.csv'

# ----
# ## 干活
def csv_to_html
  xin_csv_2_html CSV_FILEFODLER, OUTPUT
  copy_asset_to_output
end
