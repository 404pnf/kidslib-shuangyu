# # 这个脚本不需要使用了。因为一二期csv到html的转换脚本已经统一了

require 'find'
require 'csv'
require 'erubis'
require 'pp'
require 'fileutils'

CSV_FILEFODLER = 'db/1qi-csv/'
OUTPUT = 'output'
VIEW_FOLDER = 'views'
TPL_FILE = 'views/book.erubis.html'
BOOK_TITLES = 'db/book_titles.csv'

def csv_2_html
  files = Find.find(CSV_FILEFODLER).select { |f| f =~ /csv$/}
  titles = CSV.readlines(BOOK_TITLES).reduce(Hash.new) do |h, arr|
    h[arr[0].to_s] = [arr[1], arr[2]]
    h
  end
  files.each do |file|
    id = File.basename(file, '.csv')
    title = titles[id].join(' | ') unless titles[id].nil?
    paragraphs = CSV.readlines file
    eruby = Erubis::Eruby.new(File.read(TPL_FILE))
    html_str =  eruby.result(binding())
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

if __FILE__ == $PROGRAM_NAME
  csv_2_html
  copy_asset_to_output
end
