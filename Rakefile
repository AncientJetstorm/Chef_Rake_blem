require 'rake/packagetask'

task :default => :createApp

task :createApp do
	start
end

def start
	data = IO.readlines("config.txt")
	count = 0
	create = 'n'
	for i in 0..data.length - 8
    charttype = data[i].scan(/ChartType: "(.*)" RowType:/)[0][0]
    if (charttype == 'text' or charttype == 'radio' or charttype == 'dropdown' or charttype == 'checkboxgroup' or charttype == 'multiselect' or charttype == 'timerangepicker')
    else
    	count += 1
    end
	end
	if count >= 14
		puts ""
		puts "WARNING! There would be 14 or more searches happening in this app.
		Splunk will not run more then 14 searches at one time.
		The app can be created, but any chart after 14 will not work."
		puts ""
		STDOUT.puts "Create anyway? (y/n)"
		create = STDIN.gets.strip
	end
	if create == 'y'
		app_name = data[0].scan(/AppName: "(.*)" Search:/)[0][0]
		ruby "createApp2.rb"
		status "App created"
		STDOUT.puts "Package App? (y/n)"
		input = STDIN.gets.strip
		if input == 'y'
			sh "tar cv " + app_name + "/ > " + app_name + ".tar"
			sh "gzip " + app_name + ".tar"
			sh "mv " + app_name + ".tar.gz " + app_name + ".spl"
			puts ""
			status "Install file through Splunk instance"
			status "Then restart the Splunk instance"
		end
		puts ""
	else
		status "Build quit"
	end
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
