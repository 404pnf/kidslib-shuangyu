require_relative 'get-fenlei-nl.rb'
require_relative 'csv_to_html.rb'

# ## a timer
def time(&block)
  t = Time.now
  result = block.call
  puts "\nCompleted in #{(Time.now - t)} seconds\n\n"
  result
end

desc "help msg"
task :help do
  system('rake -T')
end

desc "generate html"
task :gen do
  time { csv_to_html }
end

desc "generate fenlei"
task :fenlei do
  input = 'db/all-csv' 
  #time { Kidslib.get_fenlei_nianling(input) }
  Kidslib.get_fenlei_nianling(input)
end

desc "deploy"
task :deploy do
  system("rsync -avz _output/* wxkj:/var/www/ilearning/bilingual/")
  puts "\n\n同步到服务器了"
end

desc "generate and deploy"
task :all => [:gen, :deploy] do
  puts "\nRake: 生成html并部署到服务器了。"
end

desc "preview html"
task :preview do
  system("python -m SimpleHTTPServer")
end

desc "generating docs"
task :doc do
  system("docco *.rb")
end

desc "show stats of line of code "
task :loc do
  system("cloc *.rb")
end

desc "run robocop"
task :cop do
  system("rubocop *.rb")
end

desc "review metrics of codes"
task :review => [:doc, :loc, :cop]

task :default => [:help]
