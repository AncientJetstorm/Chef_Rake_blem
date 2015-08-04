file_name = "temp_testing.txt";

task :default => :firstTask

task :firstTask do
	puts "Testing"
end

task :secondTask do
	test
end

def test
	sh "cat temp_testing.txt"
end