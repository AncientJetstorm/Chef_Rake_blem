require 'rake/packagetask'

task :default => :createApp

task :createApp do
	start
end

def start
	data = IO.readlines("config.txt")
	if (!errorChecks(data))
		count = 0
		create = 'y'
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
end

def errorChecks(file)
	rdouble = 0
	rtriple = 0
	if file[0].scan(/AppName: (.*) Search:/)[0][0] == "\"\""
		puts ""
		puts "Error! No app name defined."
		puts ""
		return true
	end
	for i in 0..file.length - 8
		rowState = file[i].scan(/RowType: (.*) PanelName:/)[0][0]
		search = file[i].scan(/Search: (.*) ChartType:/)[0][0]
		charttype = file[i].scan(/ChartType: (.*) RowType:/)[0][0]
		if file[i].include? 'ColorScheme'
			panelname = file[i].scan(/PanelName: (.*) ColorScheme:/)[0][0]
			colorscheme = file[i].scan(/ColorScheme: (.*)"/)[0][0]
		if colorscheme == "\""
			puts "
Error! Row #{i + 1} does not have a ColorScheme.
ColorScheme is not required, but remove it if it is not being used.
Package not created."
			puts ""
			return true
		end
		elsif file[i].include? 'Choices'
			panelname = file[i].scan(/PanelName: (.*) Choices:/)[0][0]
			choices = file[i].scan(/Choices: (.*)"/)[0][0]
		if panelname == "\""
			puts "
Error! Row #{i + 1} does not have Choices.
Package not created."
			puts ""
			return true
		end
		else
			panelname = file[i].scan(/PanelName: (.*)"/)[0][0]
		end
		if rowState == "\"\""
			puts "
Error! Row #{i + 1} does not have a RowType.
Package not created."
			puts ""
			return true
		end
		if search == "\"\""
			puts "
Error! Row #{i + 1} does not have a Search.
Package not created."
			puts ""
			return true
		end
		if charttype == "\"\""
puts "
Error! Row #{i + 1} does not have a ChartType.
Package not created."
			puts ""
			return true
		end
		if panelname == "\""
			puts "
Error! Row #{i + 1} does not have a PanelName.
Package not created."
			puts ""
			return true
		end
		if (rowState == "\"double\"")
			if rdouble == 0
				rdouble += 1
			else
				rdouble = 0
			end
		elsif (rowState == "\"triple\"")
			if rtriple <= 1
				rtriple += 1
			else
				rtriple = 0
			end
		else
			if rdouble == 1
				puts ""
				puts "Error! Row #{i} does not have a follow up for the double row type.
				Package not created."
				puts ""
				return true
			elsif rtriple >= 1
				puts ""
				puts "Error! Row #{i} does not have a follow up for the triple row type.
				Package not created."
				puts ""
				return true
			end
		end
	end
	return false
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
