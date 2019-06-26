#strCommand = "copy tmx\\*.tmx ."
#puts strCommand
#system strCommand

d = Dir.entries(".").select { | f |
	File.file? f
	f =~ /.*\.tmx$/
}



d.each { | f |
	f = f.split(".")[0]
	
	strCommand = "del #{f}.txt"
	puts strCommand
	system strCommand
	
#	strCommand = "ren #{f}.tmx #{f}.txt"
	strCommand = "copy #{f}.tmx #{f}.txt"
	puts strCommand
	system strCommand
}