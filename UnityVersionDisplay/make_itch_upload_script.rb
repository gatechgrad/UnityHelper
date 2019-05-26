### 2018 Levi D. Smith
### levidsmith.com

require 'fileutils'


def makeItchUploadScript(proj_name, itch_id, proj_dir)

out_dir = "out"
#proj_name = ARGV[0]
#itch_id = ARGV[1]
#proj_dir = 'E:/ldsmith/projects/'

puts "MakeItchUploadScript: " + proj_name + ", " + itch_id + ", " + proj_dir


if (!proj_name.nil? && !itch_id.nil?) 
	puts "Project Name: #{proj_name}"
	puts "Itch ID: #{itch_id}"
	puts "--------------------------"
	
	
	if (!File.directory?(out_dir))
		FileUtils.mkdir out_dir
	end

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
	
	FileUtils.mv("out/butler_push_all.bat", "#{proj_dir + "/" + proj_name}")

	
elsif
	puts "Usage: ruby make_build_scripts.rb <ProjectName> <ItchID>"
end

end