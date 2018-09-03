PROJECTS_DIR='E:/ldsmith/projects'

def displayProjects()
	puts "Projects: #{PROJECTS_DIR}"
	
	Dir.entries(PROJECTS_DIR).select { | entry |
		if (entry != '.' || entry != '..')
			
			strEntryPath = File.join(PROJECTS_DIR, entry)
			if (File.directory?(strEntryPath)) 
			
				hasPrintedProjectName = false
				Dir.entries(strEntryPath).select { | strFileName |
					if (strFileName != '.' && strFileName != '..')

						if ((strFileName.end_with? "Editor.csproj") && (strFileName != "Assembly-CSharp-Editor.csproj"))
							if (!hasPrintedProjectName)
								puts "#{entry}"			
								hasPrintedProjectName = true
							end
						
							strEditorFile = File.join(strEntryPath, strFileName)
							File.open(strEditorFile).each do | line |
								if (line =~ /<UnityVersion>(.*)<\/UnityVersion>/)
									puts "  Unity Version: " + $1 + " (#{strFileName})"
								end
							
								
							end
							
						end
					end
				}
				
				strProjectVersionFile = 'ProjectSettings/ProjectVersion.txt'
				strProjectVersionPath = File.join(strEntryPath, strProjectVersionFile)
				if (File.file?(strProjectVersionPath))
					if (!hasPrintedProjectName)
						puts "#{entry}"			
						hasPrintedProjectName = true
					end

					File.open(strProjectVersionPath).each do | line |
						if (line =~ /m_EditorVersion: (.*)/)
							puts "  Unity Version: " + $1 + " (#{strProjectVersionFile})"
							
						end
					end
				
				end
			end
			
		end
	}
end



def main()
	displayProjects()
end


main()