### 2018 Levi D. Smith
### levidsmith.com

require 'fileutils'

strBaseDir = 'E:/ldsmith/projects'
strUnityExe = '"E:/Program Files/Unity/Editor/Unity.exe"'


arrGames = [ 
#             ['AncientAdventure', 'ancient-adventure'],
			 ['AgentsVsAliens', 'agents-vs-aliens'],
			 ['AmishBrothers', 'amish-brothers']
			]

arrGames.each { | arrGame |
	strGame = arrGame[0]
	strDir = strBaseDir + '/' + strGame
	puts "Game: #{strDir}"
	FileUtils.cd(strDir)
#	system("dir")
#	system("build_all.bat")

#    proj_dir=E:\ldsmith\projects\AmishBrothers

#system("dir")
strCommand = "#{strUnityExe} -batchmode -logFile -projectPath #{strDir} -buildLinuxUniversalPlayer build\\#{strGame}Linux\\#{strGame} -quit"
puts (strCommand)
system(strCommand)

strCommand = "#{strUnityExe} -batchmode -logFile -projectPath #{strDir} -buildOSXUniversalPlayer build\\#{strGame}Mac\\#{strGame}.app -quit"
puts (strCommand)
system(strCommand)

strCommand = "#{strUnityExe} -batchmode -logFile -projectPath #{strDir} -buildWindowsPlayer build\\#{strGame}Mac\\#{strGame}.exe -quit"
puts (strCommand)
system(strCommand)


sleep(10)


}