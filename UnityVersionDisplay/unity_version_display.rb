PROJECTS_DIR='E:\ldsmith\projects'

def displayProjects()
	puts "Projects: #{PROJECTS_DIR}"
	
	Dir.entries(PROJECTS_DIR).select { | entry |
		if (entry != '.' || entry != '..')
			
			
			strEntryPath = File.join(PROJECTS_DIR, entry)
			if (File.directory?(strEntryPath)) 
			

				
				hasPrintedProjectName = false
				Dir.entries(File.join(PROJECTS_DIR, entry)).select { | strFileName |
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
			end
			
		end
	}
end



def main()
	displayProjects()
end


main()