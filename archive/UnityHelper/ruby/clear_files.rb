#strCommand = "copy tmx\\*.tmx ."
#puts strCommand
#system strCommand

d = Dir.entries(".").select { | f |
	File.file? f
	f =~ /.*\.JPG$/
}



d.each { | f |
	strCommand = "type NUL > #{f}"
	puts strCommand
	system strCommand

=begin
	f = f.split(".")[0]
	
	strCommand = "del #{f}.txt"
	puts strCommand
	system strCommand
	
	strCommand = "copy #{f}.tmx #{f}.txt"
	puts strCommand
	system strCommand
=end
}