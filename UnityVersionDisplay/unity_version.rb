### 2018 Levi D. Smith
### levidsmith.com

require 'fileutils'

#PROJECTS_DIR='E:/ldsmith/projects'
#UNITY_CURRENT_VERSION = "2018.2.6f1"
#PLAYMAKER_CURRENT_VERSION = "1.9.0"
#UNITY_EXE = 'E:/Program Files/Unity/Editor/Unity.exe'

class Config
	attr_accessor :projects_dir
	attr_accessor :unity_current_version
	attr_accessor :playmaker_current_version
	attr_accessor :unity_exe
end

class GameProject
		attr_accessor :name
		attr_accessor :versions
		attr_accessor :playmaker_version
		attr_accessor :hasUnityPackageManagerFolder
		attr_accessor :hasTempFolder
		
		def hasCurrentVersion
			
			return true
		end
end

class UnityVersion
	attr_accessor :versionNumber
	attr_accessor :fileName
end


def displayProjects(strProjectsDir, strCurrentVersion)
	gameProjectList = Array.new
	
	strResult = ""
	puts "Projects: #{strProjectsDir}"
	
	if (!File.directory?(strProjectsDir))
		puts "Directory #{strProjectsDir} does not exist!"
		return nil
	end
	
	Dir.entries(strProjectsDir).select { | entry |
		if (entry != '.' || entry != '..')
			
			strEntryPath = File.join(strProjectsDir, entry)
			if (File.directory?(strEntryPath) && File.directory?(strEntryPath + "/Assets") )
				game = GameProject.new
			
				
#				hasPrintedProjectName = false
				game.name = entry
				game.versions = Array.new
				
				Dir.entries(strEntryPath).select { | strFileName |
					if (strFileName != '.' && strFileName != '..')

#						if ((strFileName.end_with? "Editor.csproj") && (strFileName != "Assembly-CSharp-Editor.csproj"))

						if (strFileName.end_with? ".csproj")
						
#							if (!hasPrintedProjectName)
#								strResult << "#{entry}" + "\n"
#								hasPrintedProjectName = true
#							end
						
							strEditorFile = File.join(strEntryPath, strFileName)
							f = File.open(strEditorFile, "r")
							f.each do | line |
								if (line =~ /<UnityVersion>(.*)<\/UnityVersion>/)
									strResult << "  Unity Version: " + $1 + " (#{strFileName})" + "\n"

									version = UnityVersion.new
									version.versionNumber = $1
									version.fileName = strFileName
									game.versions << version

								end
							
								
							end
							f.close
							
						end
					end
				}
				
				strProjectVersionFile = 'ProjectSettings/ProjectVersion.txt'
				strProjectVersionPath = File.join(strEntryPath, strProjectVersionFile)
				if (File.file?(strProjectVersionPath))
#					if (!hasPrintedProjectName)
#						strResult << "#{entry}" + "\n"
#						hasPrintedProjectName = true
#					end

					f = File.open(strProjectVersionPath, "r")
					f.each do | line |
						if (line =~ /m_EditorVersion: (.*)/)
							strVersion = $1
							strResult << "  Unity Version: " + $1 + " (#{strProjectVersionFile})"
							
							version = UnityVersion.new
							version.versionNumber = $1
							version.fileName = strProjectVersionFile
							game.versions << version
							
							if (strVersion == strCurrentVersion)
								strResult << "[ OK ]"
							else 
								strResult << "[ NOT CURRENT VERSION ]"
							end
							
							strResult << "\n"
						end
					end
					f.close
				
				end
				
				
				if (File.directory?(File.join(strEntryPath, "UnityPackageManager")))
					strResult << "  Delete UnityPackageManager directory after upgrading to Unity 2018.2" + "\n"
				end
				
				if (File.directory?(File.join(strEntryPath, "Temp")))
					strResult << "  Consider deleting Temp folder" + "\n"
				end
				
				strWelcomeWindowFileName = "Assets/PlayMaker/Editor/PlayMakerWelcomeWindow.cs"
				if (File.file?(File.join(strEntryPath, strWelcomeWindowFileName)))
					f = File.open(File.join(strEntryPath, strWelcomeWindowFileName), "r")
					f.each do | line |
						if (line =~ /InstallCurrentVersion = "(.*)";/)
							strVersion = $1
#							strResult << "  PlayMaker Version: " + $1
							
							game.playmaker_version = $1
							
						end
					end
					f.close

#					game.playmaker_version = '?'

				
				end
#				game.playmaker_version = '??'
				

				gameProjectList << game
				
			end
			
		end
	}
	
	
#	puts strResult
	
#	return strResult
	return gameProjectList
end

def compileWebGL(games)
	games.each do | game |
		puts "WebGL compile: #{game.name}"
		dirProject = File.join($config.projects_dir, game.name)
		dirBuild = File.join($config.projects_dir, game.name, "build", "#{game.name}WebGL")
		puts "build directory #{dirBuild}"
		FileUtils.rm_rf(dirBuild)
		
		
#		strCommand = '"' + UNITY_EXE + '" -batchmode -logFile -projectPath ' + dirProject + ' -buildLinuxUniversalPlayer ' + dirBuild + ' -quit'
#		strCommand = '"' + UNITY_EXE + '" -logFile -projectPath ' + dirProject + ' -buildLinuxUniversalPlayer ' + dirBuild + ' -quit'

#Must generate the build script first...
		strBuildContents = ""
		
		strScenes = ""
		Dir.entries(File.join(dirProject, "Assets/Scenes")).select { | strFileName |
			if (strFileName != '.' && strFileName != '..')

				if (strFileName.end_with? ".unity")
				
					if (strScenes != "")
						strScenes << ', '
					end
					strScenes << '"Assets/Scenes/' + strFileName + '"'
			
				end
			end
		}
			

		
		
		fTempFile = File.open("MyEditorScript.cs.template", "r")
		fTempFile.each do | line |
			if (line =~ /(.*)(%NAME%)(.*)/)
				strBuildContents << $1 << game.name << $3 << "\n"
			elsif (line =~ /(.*)(%SCENES%)(.*)/)
				strBuildContents << $1 << strScenes << $3 << "\n"
				
			else 
				strBuildContents << line
			end
		end
		fTempFile.close
		
		puts strBuildContents
		
		if (!File.directory?(File.join(dirProject, "Assets/Editor")) )
			FileUtils.mkdir(File.join(dirProject, "Assets/Editor"))
		end 
		File.open(File.join(dirProject, "Assets/Editor/MyEditorScript.cs"), 'w') { | file |
			file.write(strBuildContents)
		
		}

		
		
		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -executeMethod MyEditorScript.PerformBuild -quit'
		puts strCommand
		system(strCommand)
		
		
		
	end

end


def clearBuildFolder(games)
	games.each do | game |
		dirProject = File.join($config.projects_dir, game.name)
		dirBuild = File.join($config.projects_dir, game.name, "build")
		puts "Clearing: #{dirBuild}"

#		puts "build directory #{dirBuild}"
#		FileUtils.rm_rf(dirBuild)

		if (File.directory?(dirBuild)) 

			Dir.entries(dirBuild).select { | strFileName |
				if (strFileName != '.' && strFileName != '..')
					filePath = File.join(dirBuild, strFileName)
					puts "Deleting " + filePath
					FileUtils.rm_rf(filePath)
				
				
			
				end
			}
		end
		
	end

end


def compileWindows(games)
	games.each do | game |
		puts "Windows compile: #{game.name}"
		dirProject = File.join($config.projects_dir, game.name)
		dirBuild = File.join($config.projects_dir, game.name, "build", "#{game.name}Windows")
		puts "build directory #{dirBuild}"
		
		if (!File.directory?(File.join($config.projects_dir, game.name, "build")))
			FileUtils.mkdir(File.join($config.projects_dir, game.name, "build"))
		else
			FileUtils.rm_rf(dirBuild)
		
		end
		
		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -buildWindowsPlayer ' + File.join(dirBuild, game.name + ".exe") + ' -quit'
		puts strCommand
		system(strCommand)
		
	end
end

def compileMac(games)
	games.each do | game |
		puts "Mac compile: #{game.name}"
		dirProject = File.join($config.projects_dir, game.name)
		dirBuild = File.join($config.projects_dir, game.name, "build", "#{game.name}Mac")
		puts "build directory #{dirBuild}"
		
		if (!File.directory?(File.join($config.projects_dir, game.name, "build")))
			FileUtils.mkdir(File.join($config.projects_dir, game.name, "build"))
		else
			FileUtils.rm_rf(dirBuild)
		
		end
		
		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -buildOSXUniversalPlayer ' + File.join(dirBuild, game.name + ".app") + ' -quit'
		puts strCommand
		system(strCommand)
		
	end
end


def compileLinux(games)
	games.each do | game |
		puts "Linux compile: #{game.name}"
		dirProject = File.join($config.projects_dir, game.name)
		dirBuild = File.join($config.projects_dir, game.name, "build", "#{game.name}Linux")
		puts "build directory #{dirBuild}"
		
		if (!File.directory?(File.join($config.projects_dir, game.name, "build")))
			FileUtils.mkdir(File.join($config.projects_dir, game.name, "build"))
		else
			FileUtils.rm_rf(dirBuild)
		
		end
		
		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -buildLinuxUniversalPlayer ' + File.join(dirBuild, game.name) + ' -quit'
		puts strCommand
		system(strCommand)
		
	end
end


def readConfigFile() 
	$config = Config.new
	
	fileConfig = File.open("unity_version.config", "r")
	fileConfig.each do | line |
		if (line =~ /UNITY_EXE: (.*)/)
			$config.unity_exe = $1
		end
		
		if (line =~ /PROJECTS_DIR: (.*)/)
			$config.projects_dir = $1
		end
		
		if (line =~ /UNITY_CURRENT_VERSION: (.*)/)
			$config.unity_current_version = $1
		end
		
		if (line =~ /PLAYMAKER_CURRENT_VERSION: (.*)/)
			$config.playmaker_current_version = $1
		end
		
		
	end
	
	fileConfig.close


end

def getUnityVersion()
	strEditorLogFile = ENV['USERPROFILE'] + '\AppData\Local\Unity\Editor\Editor.log'
#	puts "Editor Log: " + strEditorLogFile


	strVersion = ""
#	strCommand = '"' + $config.unity_exe + '"'

	f = File.open(strEditorLogFile, "r")
	f.each do | line | 
		if (line =~ /Version is '(.*) \(/)
			strVersion = $1
			puts strVersion
		end
	
	end
	f.close()
	
	strConfig = ""
	f = File.open("unity_version.config", "r")
	f.each do | line |
		if (line =~ /UNITY_CURRENT_VERSION/)
			strConfig << "UNITY_CURRENT_VERSION: " + strVersion + "\n"
		else
			strConfig << line
		end
	end
	f.close()
	
	f = File.open("unity_version.config", "w")
	f.puts strConfig
	f.close()

end

def main()
	readConfigFile
	displayProjects()
end


#main()
#getUnityVersion()