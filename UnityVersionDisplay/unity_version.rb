PROJECTS_DIR='E:/ldsmith/projects'

def displayProjects(strProjectsDir)
	strResult = ""
#	strResult << "hello"
	puts "Projects: #{strProjectsDir}"
	
	if (!File.directory?(strProjectsDir))
		return "Directory #{strProjectsDir} does not exist!"
	end
	
	Dir.entries(strProjectsDir).select { | entry |
		if (entry != '.' || entry != '..')
			
			strEntryPath = File.join(strProjectsDir, entry)
			if (File.directory?(strEntryPath)) 
			
				
				hasPrintedProjectName = false
				Dir.entries(strEntryPath).select { | strFileName |
					if (strFileName != '.' && strFileName != '..')

						if ((strFileName.end_with? "Editor.csproj") && (strFileName != "Assembly-CSharp-Editor.csproj"))
#						if (strFileName.end_with? "Editor.csproj")
							if (!hasPrintedProjectName)
#								puts "#{entry}"			
								strResult << "#{entry}" + "\n"
								hasPrintedProjectName = true
							end
						
							strEditorFile = File.join(strEntryPath, strFileName)
							File.open(strEditorFile).each do | line |
								if (line =~ /<UnityVersion>(.*)<\/UnityVersion>/)
#									puts "  Unity Version: " + $1 + " (#{strFileName})"
									strResult << "  Unity Version: " + $1 + " (#{strFileName})" + "\n"
								end
							
								
							end
							
						end
					end
				}
				
				strProjectVersionFile = 'ProjectSettings/ProjectVersion.txt'
				strProjectVersionPath = File.join(strEntryPath, strProjectVersionFile)
				if (File.file?(strProjectVersionPath))
					if (!hasPrintedProjectName)
#						puts "#{entry}"			
						strResult << "#{entry}" + "\n"
						hasPrintedProjectName = true
					end

					File.open(strProjectVersionPath).each do | line |
						if (line =~ /m_EditorVersion: (.*)/)
#							puts "  Unity Version: " + $1 + " (#{strProjectVersionFile})"
							strResult << "  Unity Version: " + $1 + " (#{strProjectVersionFile})" + "\n"
							
						end
					end
				
				end
				
				
				if (File.directory?(File.join(strEntryPath, "UnityPackageManager")))
#					puts "  Delete UnityPackageManager directory after upgrading to Unity 2018.2"
					strResult << "  Delete UnityPackageManager directory after upgrading to Unity 2018.2" + "\n"
				end
				
				if (File.directory?(File.join(strEntryPath, "Temp")))
#					puts "  Consider deleting Temp folder"
					strResult << "  Consider deleting Temp folder" + "\n"
				end

			end
			
		end
	}
	
	
#	strResult << "a" + "\n"
	puts strResult
	
	return strResult
end



def main()
	displayProjects(PROJECTS_DIR)
end


#main()