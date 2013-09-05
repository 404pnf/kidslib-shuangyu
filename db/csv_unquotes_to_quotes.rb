

def unquotes_to_quotes(file)
	CSV.read(file).map { |e| e.to_csv(force_quotes: true)}
end

def main
	Dir['*.csv'].each do |file|
		content = unquotes_to_quotes(file)
		new_filename = filename + '.quotes.csv'
		File.write(new_filename, content)
	end
end

main if __FILE__ == $PROGRAME_NAME
