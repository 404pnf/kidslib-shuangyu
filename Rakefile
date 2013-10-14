require_relative 'csv_to_html.rb'

# ## a timer
def time(&block)
  t = Time.now
  #result = block.call
  yield
  puts "\n耗时 #{(Time.now - t)} 秒\n\n"
  #result
end

desc "help msg"
task :help do
  system('rake -T')
end

desc "generate html"
task :gen do
  time { csv_to_html }
end

desc "deploy"
task :deploy do
  system("rsync -avz --quiet output/* wxkj:/var/www/ilearning/bilingual/")
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

task :default => [:help]
