file_name = "temp_testing.txt"
basicNum = 0
numberType = "nothing"
text = "nothing"
create = true

task :default => :build

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

task :build do
	createfile
end

task :getConfig do
	loadConfig
end

task :testConnection do
	sh "ping www.google.com"
end

def loadConfig
	require "./createApp.rb"
	ruby "createApp.rb"
	sh "tar cv app_name/ > app_name.tar"
	sh "gzip app_name.tar"
	sh "mv app_name.tar.gz app_name.spl"
	puts "APP FILE CREATED"
	# f = File.open("newFile.txt", "w")
	# f.write("This is the first line\n")
	# f.write("Second line")
	# f.close
end

def createfile
	allFiles = Dir.glob("*")
	create = true
	if !File.file?("config.txt")
		create = false
		fname = "config.txt"
		somefile = File.open(fname, "w")
		somefile.puts "Number: "
		somefile.puts "Type: "
		somefile.print "Text: "
		somefile.close
		puts "\nPlease fill out the config.txt file\n\n"
	end
	if create
		data = IO.readlines("config.txt")
		data[2].slice! "Text: "
		num = data[2].length
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