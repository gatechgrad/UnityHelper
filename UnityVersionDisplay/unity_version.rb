### 2018, 2019 Levi D. Smith
### levidsmith.com

require 'fileutils'
require 'zip' #gem install rubyzip
require_relative 'zip_example_recursive'
require_relative 'make_itch_upload_script'

class Config
	attr_accessor :projects_dir
	attr_accessor :unity_current_version
	attr_accessor :playmaker_current_version
	attr_accessor :unity_exe
	attr_accessor :scan_projects_on_startup
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
			
				
				game.name = entry
				game.versions = Array.new
				
				Dir.entries(strEntryPath).select { | strFileName |
					if (strFileName != '.' && strFileName != '..')


						if (strFileName.end_with? ".csproj")
						
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
							
							game.playmaker_version = $1
							
						end
					end
					f.close


				
				end
				

				gameProjectList << game
				
			end
			
		end
	}
	
	
	return gameProjectList
end

def compileWebGL(games)
	games.each do | game |
		puts "WebGL compile: #{game.name}"
		dirProject = File.join($config.projects_dir, game.name)
		dirBuild = File.join($config.projects_dir, game.name, "build", "#{game.name}WebGL")
		puts "build directory #{dirBuild}"
		FileUtils.rm_rf(dirBuild)

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
			

		
		
		fTempFile = File.open("EditorScript.cs.template", "r")
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
		File.open(File.join(dirProject, "Assets/Editor/EditorScript.cs"), 'w') { | file |
			file.write(strBuildContents)
		
		}

		
		
		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -executeMethod EditorScript.PerformBuild -quit'
		puts strCommand
		system(strCommand)
		
		
		
	end

end

def copyAutoSaveScript(games) 
	games.each do | game |
		dirProject = File.join($config.projects_dir, game.name)

		if (!File.directory?(File.join(dirProject, "Assets/Editor")) )
			FileUtils.mkdir(File.join(dirProject, "Assets/Editor"))
		end 


		FileUtils.cp("AutoSave.cs.template", File.join(dirProject, "Assets/Editor/AutoSave.cs"))
		FileUtils.cp("PackageRemover.cs.template", File.join(dirProject, "Assets/Editor/PackageRemover.cs"))

		if (!File.directory?(File.join(dirProject, "Assets/Sprites")) )
			FileUtils.mkdir(File.join(dirProject, "Assets/Sprites"))
		end 

		
		if (!File.directory?(File.join(dirProject, "Assets/Sprites/SplashScreen")) )
			FileUtils.mkdir(File.join(dirProject, "Assets/Sprites/SplashScreen"))
		end 

		
		FileUtils.cp("images/splash_background.png", File.join(dirProject, "Assets/Sprites/SplashScreen/splash_background.png"))
		FileUtils.cp("images/splash_logo.jpg", File.join(dirProject, "Assets/Sprites/SplashScreen/splash_logo.jpg"))
	end

end

def makeZipFiles(games)
	games.each do | game |
		puts "Zip build folders: #{game.name}"
		dirBuild = File.join($config.projects_dir, game.name, "build")
		puts "build directory #{dirBuild}"
		
		Dir.entries(dirBuild).select { | entry |
			strDirToZip = File.join(dirBuild, entry)
			if (entry != "." && entry != ".." && File.directory?(strDirToZip))
				strZipFile = File.join(dirBuild, entry + '.zip')
				puts "Zipping " + strDirToZip + " " + strZipFile
				
				if (File.exist?(strZipFile))
						FileUtils.rm(strZipFile)
				end
				
				zf = ZipFileGenerator.new(strDirToZip, strZipFile)
				zf.write()

			end
		
		}

		
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
		
		if (line =~ /SCAN_PROJECTS_ON_STARTUP: (.*)/)
			if ($1.upcase == "TRUE")
				$config.scan_projects_on_startup = true
			else 
				$config.scan_projects_on_startup = false
			end
		end
		
	end
	
	fileConfig.close


end

def getUnityVersion()
	strEditorLogFile = ENV['USERPROFILE'] + '\AppData\Local\Unity\Editor\Editor.log'


	strVersion = ""

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

def makeUploadScript(game, strProjectIdentifier)
	makeItchUploadScript(game.name, strProjectIdentifier, $config.projects_dir)

end

def main()
	readConfigFile
	displayProjects()
end
