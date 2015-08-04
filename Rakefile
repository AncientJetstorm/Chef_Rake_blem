file_name = "temp_testing.txt";

task :default => :firstTask

task :firstTask do
	puts "Testing"
end

task :secondTask do
	if File.exist?(file_name) do
		file = File.open(file_name)
		file.readline
		file.close
  	end
end