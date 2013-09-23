
require 'find'
require 'csv'
require 'erubis'
require 'pp'
require 'fileutils'

CSV_FILEFODLER = 'db/2qi-csv/'
OUTPUT = 'output'
VIEW_FOLDER = 'views'
TPL_FILE = 'views/book.erubis.html'
BOOK_TITLES = 'db/xin-book-titles.csv'
SUFFIX = '.csv'

def xin_csv_2_html
  files = Find.find(CSV_FILEFODLER).select { |f| f =~ /#{ SUFFIX }$/}
  titles = CSV.readlines(BOOK_TITLES).each_with_object(Hash.new) do |e, a|
    id, *title = e
    a[id] = title
  end
  # pp titles
  files.each do |file|
    id = File.basename(file, SUFFIX)
    title = titles[id].join(' | ') unless titles[id].nil?
    # 二期中英文顺序和一期相反的
    paragraphs = CSV.readlines(file).map { |(en, zh)| [zh, en] }

    eruby = Erubis::Eruby.new(File.read(TPL_FILE)) # create Eruby object
    html_str =  eruby.result(binding())   # TODO get result; all local variables are available in the template, might not be a good idea

    p "generating #{OUTPUT}/#{id}.html: #{title}"
    File.write("#{OUTPUT}/#{id}.html", html_str)
  end
end

def copy_asset_to_output
  # If you want to copy all contents of a directory instead of the
  # directory itself, c.f. src/x -> dest/x, src/y -> dest/y,
  # use following code.
  # cp_r('src', 'dest') makes dest/src,
  # but this doesn't.
  FileUtils.cp_r 'views/.', 'output', :verbose => true
end

def suceed_msg
  # 友情提示
  p ''
  p '------------'
  p '友情提示'
  p '-------------'
  p ''
  p "生成的文件在： #{OUTPUT}"
end

if __FILE__ == $PROGRAM_NAME
  xin_csv_2_html
  copy_asset_to_outputr
  #suceed_msg
end
