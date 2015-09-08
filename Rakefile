require 'yaml'

task :default => :createApp

task :createApp do
	start
end

def start
	yamldata = YAML.load_file('config.yaml')
	unless (errorChecks(yamldata))
		count = 0
		create = 'y'
		yamldata.each_key { |key|
			unless yamldata[key].include?('Extra')
		    charttype = yamldata[key]['ChartType']
		    unless (charttype == 'text' or charttype == 'radio' or charttype == 'dropdown' or charttype == 'checkboxgroup' or charttype == 'multiselect' or charttype == 'timerangepicker')
		    	count += 1
		    end
	  	end
	  }
		if count >= 14
			puts ''
			puts 'WARNING! There would be 14 or more searches happening in this app.
			Splunk will not run more then 14 searches at one time.
			The app can be created, but any chart after 14 will not work.'
			puts ''
			STDOUT.puts 'Create anyway? (y/n)'
			create = STDIN.gets.strip
		end
		if create == 'y'
			app_name = yamldata['Chart1']['AppName']
			status "Creating #{app_name}..."
			ruby 'createApp2.rb'
			status 'App created'
			puts ''
		else
			status 'Build quit'
		end
	end
end

def errorChecks(file)
	rdouble = 0
	rtriple = 0
	if file['Chart1']['AppName'] == '' or file['Chart1']['AppName'] == nil
		puts ''
		puts 'Error! No app name defined.'
		puts ''
		return true
	end
	file.each_key { |key|
		unless file[key].include?('Extra')
			rowState = file[key]['RowType'].downcase
			search = file[key]['Search']
			charttype = file[key]['ChartType']
			panelname = file[key]['PanelName']
			if file[key].include?('ColorScheme')
				colorscheme = file[key]['ColorScheme']
				if colorscheme == '' or colorscheme == nil
					puts "
Error! #{key} does not have a ColorScheme.
	ColorScheme is not required, but remove it if it is not being used.
	Package not created."
					puts ''
					return true
				end
			end
			if file[key].include?('Choices')
				choices = file[key]['Choices']
				if choices == '' or choices == nil
					puts "
Error! #{key} does not have Choices.
	Package not created."
					puts ''
					return true
				end
			end
			if rowState == '' or rowState == nil
				puts "
Error! #{key} does not have a RowType.
	Package not created."
				puts ''
				return true
			end
			if search == '' or search == nil
				puts "
Error! #{key} does not have a Search.
	Package not created."
				puts ''
				return true
			end
			if charttype == '' or charttype == nil
	puts "
Error! #{key} does not have a ChartType.
	Package not created."
				puts ''
				return true
			end
			if panelname == '' or panelname == nil
				puts "
Error! #{key} does not have a PanelName.
	Package not created."
				puts ''
				return true
			end
			if (rowState == 'double')
				if rdouble == 0
					rdouble += 1
				else
					rdouble = 0
				end
			elsif (rowState == 'triple')
				if rtriple <= 1
					rtriple += 1
				else
					rtriple = 0
				end
			else
				if rdouble == 1
					puts ''
					puts "Error! #{key} does not have a follow up for the double row type.
					Package not created."
					puts ''
					return true
				elsif rtriple >= 1
					puts ''
					puts "Error! #{key} does not have a follow up for the triple row type.
					Package not created."
					puts ''
					return true
				end
			end
		end
	}
	return false
end

def status(text)
	num = text.length
	print '+---'
	for i in 0..num
		print '-'
	end
	puts '---+'
	print '|   '
	for i in 0..num
		print ' '
	end
	puts '   |'
	print '|   '
	for i in 0..num
		print text[i]
	end
	puts '    |'
	print '|   '
	for i in 0..num
		print ' '
	end
	puts '   |'
	print '+---'
	for i in 0..num
		print '-'
	end
	puts '---+'
end
