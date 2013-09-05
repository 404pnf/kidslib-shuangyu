require 'csv'

def unquotes_to_quotes(file)
	#CSV.read(file).map { |e| e.to_csv(force_quotes: true)}
	CSV.read(file).map { |e| e.to_csv(force_quotes: true).sub("\n", '') }.join("\n")
end

def main(file)
	content = unquotes_to_quotes(file)
	new_file = file + '.quotes.csv'
	File.write(new_file, content)
end

main(ARGV[0]) if __FILE__ == $PROGRAM_NAME
