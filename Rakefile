file_name = "temp_testing.txt";

task :default => :firstTask

task :firstTask do
	puts "Testing"
end

task :secondTask do
	test
end

task :thirdTask do
	other
end

def test
	sh "cat temp_testing.txt"
end

def other
	data = File.read("temp_testing.txt")
	puts data.delete("Number: ").to_i * 2
end