require 'fileutils'

out_dir = "out"
proj_name = ARGV[0]
itch_id = ARGV[1]


if (!proj_name.nil? && !itch_id.nil?) 
	puts "Project Name: #{proj_name}"
	puts "Itch ID: #{itch_id}"
	puts "--------------------------"
	
	f = File.open("build_all.bat.template", "r")
	arrFile = f.readlines
	strFile = arrFile.join()
	strFile.gsub!( /<PROJ_NAME>/, "#{proj_name}" )
#	strFile.gsub!( /<ITCH_ID>/, "#{itch_id}" )
	puts strFile
	f.close()
	
	if (!File.directory?(out_dir))
		FileUtils.mkdir out_dir
	end
	
	f = File.open("out/build_all.bat", "w")
	f.puts(strFile)
	f.close()


	puts "--------------------------"

	f = File.open("butler_push_all.bat.template", "r")
	arrFile = f.readlines
	strFile = arrFile.join()
	strFile.gsub!( /<PROJ_NAME>/, "#{proj_name}" )
	strFile.gsub!( /<ITCH_ID>/, "#{itch_id}" )
	puts strFile
	f.close()
	
	f = File.open("out/butler_push_all.bat", "w")
	f.puts(strFile)
	f.close()

	
elsif
	puts "Usage: ruby make_build_scripts.rb <ProjectName> <ItchID>"
end