require 'csv'

def get_fenlei_nianling(path)
  get = -> f { e = CSV.table(f)[0] ; [e[:zh], e[:en], f.sub('.csv', '').sub(path, '')] }
  nl = -> { rand(2) == 1 ? '7-9岁' : '10-12岁' }
  to_csv_str = -> arr {arr.each_with_object('') { |e, o| o << e.to_csv(force_quotes: true)}}
  p 'hi'
  f = Dir.chdir(path) { Dir['*.csv'] }
  a = f.map { |e| get[e] + [nl.call] }
  aa = a.map { |zh, en, id, nianling| [id, nianling, '双语阅读', zh, en] }
  s = to_csv_str[aa]
  File.write('fenlei.csv', s)
end

get_fenlei_nianling('all-csv')
