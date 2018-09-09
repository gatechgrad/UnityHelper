### 2018 Levi D. Smith
### levidsmith.com

PROJECTS_DIR='E:/ldsmith/projects'
UNITY_CURRENT_VERSION = "2018.2.6f1"

class GameProject
		attr_accessor :name
		attr_accessor :versions
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

				gameProjectList << game
				
			end
			
		end
	}
	
	
#	puts strResult
	
#	return strResult
	return gameProjectList
end



def main()
	displayProjects(PROJECTS_DIR)
end


#main()