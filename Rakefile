file_name = "temp_testing.txt"
basicNum = 0
numberType = "nothing"
text = "nothing"

task :default => :random

task :firstTask do
	puts "Testing"
end

task :secondTask do
	test
end

task :thirdTask do
	other
end


task :byTwo do
	yep
end

def test
	sh "cat config.txt"
end

def other
	data = File.read("config.txt")
	puts data.delete("Number: ").to_i * 2
end

def yep
	data = IO.readlines("config.txt")
	data[0].slice! "Number: "
	if data[1].include? "multiply"
		puts data[0].to_i * 2
	elsif data[1].include? "add"
		puts data[0].to_i + 2
	elsif data[1].include? "subtract"
		puts data[0].to_i - 2
	elsif data[1].include? "divide"
		puts data[0].to_i / 2
	end
end

task :build => :getConfig do
	createfile
end

task :getConfig do
	loadConfig
end

task :testConnection do
	sh "ping www.google.com"
end

def loadConfig
	if !File.file?("config.txt")
		fname = "config.txt"
		somefile = File.open(fname, "w")
		somefile.puts "Number: "
		somefile.puts "Type: "
		somefile.puts "Text: "
		somefile.close
	end
end

def createfile
	data = IO.readlines("config.txt")
	data[2].slice! "Text: "
	num = data[2].length
	puts data[2]
	fname = "sample.txt"
	somefile = File.open(fname, "w")
	somefile.print "+---"
	for i in 0...num
		somefile.print "-"
	end
	somefile.puts "---+"
	somefile.print "|   "
	for i in 0...num
		somefile.print " "
	end
	somefile.puts "   |"
	somefile.print "|   "
	for i in 0...num
		somefile.print data[2][i]
	end
	somefile.puts "   |"
	somefile.print "|   "
	for i in 0...num
		somefile.print " "
	end
	somefile.puts "   |"
	somefile.print "+---"
	for i in 0...num
		somefile.print "-"
	end
	somefile.puts "---+"
	somefile.close
end

def board
	data = IO.readlines("config.txt")
	data[2].slice! "Text: "
	num = data[2].length
	print "+---"
	for i in 0..num
		print "-"
	end
	puts "---+"
	print "|   "
	for i in 0..num
		print " "
	end
	puts "   |"
	print "|   "
	for i in 0..num
		print data[2][i]
	end
	puts "    |"
	print "|   "
	for i in 0..num
		print " "
	end
	puts "   |"
	print "+---"
	for i in 0..num
		print "-"
	end
	puts "---+"
end