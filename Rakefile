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


task :byTwo do
	yep
end

def test
	sh "cat temp_testing.txt"
end

def other
	data = File.read("temp_testing.txt")
	puts data.delete("Number: ").to_i * 2
end

def yep
	data = IO.readlines("temp_testing.txt")
	data[0].slice! "Number: "
	data[1].slice! "Type: "
	if data[1] == "multiply"
		puts data[0].to_i * 2
	elsif data[1] == "add"
		puts data[0].to_i + 2
	elsif data[1] == "subtract"
		puts data[0].to_i - 2
	elsif data[1] == "divide"
		puts data[0].to_i / 2
	end
end