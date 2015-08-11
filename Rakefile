require 'rake/packagetask'

task :default => :createApp

task :createApp do
	start
end

def start
	data = IO.readlines("config.txt")
	app_name = data[0].scan(/AppName: "(.*)" Search:/)[0][0]
	puts "#{app_name}"
	# ruby "createApp2.rb"
	# status "App created"
 #  	STDOUT.puts "Package App? (y/n)"
 #  	input = STDIN.gets.strip
 #  	if input == 'y'
	# 	sh "tar cv " + app_name + "/ > " + app_name + ".tar"
	# 	sh "gzip " + app_name + ".tar"
	# 	sh "mv " + app_name + ".tar.gz " + app_name + ".spl"
	# 	puts ""
	# 	status "Install file through Splunk instance"
	# 	status "Then restart the Splunk instance"
	# end
	puts ""
end

def status(text)
	num = text.length
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
		print text[i]
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