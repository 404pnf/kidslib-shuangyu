require 'find'
require 'csv'
require 'erubis'
require 'pp'
require 'fileutils'

CSV_FILEFODLER = 'db/2qi-csv/'
OUTPUT = 'output-html'
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
    paragraphs = CSV.readlines file

    eruby = Erubis::Eruby.new(File.read(TPL_FILE)) # create Eruby object
    html_str =  eruby.result(binding())   # TODO get result; all local variables are available in the template, might not be a good idea

    p "generating #{OUTPUT}/#{id}.html: #{title}"
    File.write("#{OUTPUT}/#{id}.html", html_str)
  end
end

def copy_js_css_2_ouputfolder
  # copy necessary js/css files from views/ to output-html
  # ref: http://www.ruby-doc.org/stdlib-2.0/libdoc/fileutils/rdoc/FileUtils.html#method-c-copy
  FileUtils.cp_r Dir.glob("#{VIEW_FOLDER}/*.js"), OUTPUT, :noop => false, :verbose => true
  FileUtils.cp_r Dir.glob("#{VIEW_FOLDER}/*.css"), OUTPUT, :noop => false, :verbose => true
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
  #copy_js_css_2_ouputfolder
  #suceed_msg
end
