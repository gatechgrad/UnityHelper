### 2018 Levi D. Smith
### levidsmith.com

require 'fileutils'

PROJECTS_DIR='E:/ldsmith/projects'
UNITY_CURRENT_VERSION = "2018.2.6f1"
PLAYMAKER_CURRENT_VERSION = "1.9.0"

UNITY_EXE = 'E:/Program Files/Unity/Editor/Unity.exe'

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
		return "Directory #{strProjectsDir} does not exist!"
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

						if ((strFileName.end_with? "Editor.csproj") && (strFileName != "Assembly-CSharp-Editor.csproj"))
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
		dirProject = File.join(PROJECTS_DIR, game.name)
		dirBuild = File.join(PROJECTS_DIR, game.name, "build", "#{game.name}WebGL")
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

		
		
		strCommand = '"' + UNITY_EXE + '" -logFile -projectPath ' + dirProject + ' -executeMethod MyEditorScript.PerformBuild -quit'
		puts strCommand
		system(strCommand)
		
		
		
	end

end



def main()
	displayProjects()
end


#main()