### 2018, 2019 Levi D. Smith
### levidsmith.com

require 'fileutils'
require 'zip' #gem install rubyzip
require_relative 'zip_example_recursive'
require_relative 'make_itch_upload_script'

CONFIG_FILE = "unityhelper.config"
IGNORE_FILE = "ignore.config"

class Config
	attr_accessor :projects_dir
	attr_accessor :unity_folder
	attr_accessor :unity_selected_version
	attr_accessor :playmaker_current_version
#	attr_accessor :unity_exe
	attr_accessor :scan_projects_on_startup
	attr_accessor :company_name
	attr_accessor :butler_exe
	attr_accessor :itch_username
	
	def getUnityExe()
		return File.join(unity_folder, unity_selected_version.ToString(), "Editor/Unity.exe")
	end
end

class GameProject
		attr_accessor :name
		attr_accessor :versions
		attr_accessor :playmaker_version
		attr_accessor :hasUnityPackageManagerFolder
		attr_accessor :hasTempFolder
		attr_accessor :slug
		
		def hasCurrentVersion
			
			return true
		end
end

class UnityVersion
#	attr_accessor :versionNumber
#	attr_accessor :fileName
	
	attr_accessor :versionYear
	attr_accessor :versionMajor
	attr_accessor :versionMinor
	attr_accessor :versionPatch
	attr_accessor :versionPatchNumber
	
	
	
	def ToString()
		return "#{versionYear}.#{versionMajor}.#{versionMinor}#{versionPatch}#{versionPatchNumber}"
	end
end

class ProjectVersion
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
	
	
	ignoredProjects = Array.new
	if (File.file?(IGNORE_FILE)) 
		puts "reading #{IGNORE_FILE}"
		fileIgnore = File.open(IGNORE_FILE, "r")
		fileIgnore.each do | line |
			puts "Ignoring #{line.chomp}"
			ignoredProjects << line.chomp
		end
		fileIgnore.close
	end
	
	Dir.entries(strProjectsDir).select { | entry |
		if (entry != '.' && entry != '..' && !ignoredProjects.include?(entry))
			
			strEntryPath = File.join(strProjectsDir, entry)
			if (File.directory?(strEntryPath) && File.directory?(strEntryPath + "/Assets"))
				game = GameProject.new
			
				
				game.name = entry
				game.versions = Array.new
				game.slug = "slug"
				
				Dir.entries(strEntryPath).select { | strFileName |
					if (strFileName != '.' && strFileName != '..')


						if (strFileName.end_with? ".csproj")
						
							strEditorFile = File.join(strEntryPath, strFileName)
							f = File.open(strEditorFile, "r")
							f.each do | line |
								if (line =~ /<UnityVersion>(.*)<\/UnityVersion>/)
									strResult << "  Unity Version: " + $1 + " (#{strFileName})" + "\n"

									version = ProjectVersion.new
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
							
							version = ProjectVersion.new
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
#						if (line =~ /InstallCurrentVersion = "(.*)";/)
						if (line =~ /InstallAssemblyVersion = "(.*)";/)
							strVersion = $1
							
							game.playmaker_version = $1
							
						end
					end
					f.close


				
				end
				
				game.slug = getSlugFromConfigFile(game.name)
				

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

		
		
#		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -executeMethod EditorScript.PerformBuild -quit'
		strCommand = '"' + $config.getUnityExe() + '" -logFile -projectPath ' + dirProject + ' -executeMethod EditorScript.PerformBuild -quit'
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
		
		if (File.directory?(dirBuild))
		
			Dir.entries(dirBuild).select { | entry |
				strDirToZip = File.join(dirBuild, entry)
				if (entry != "." && entry != ".." && File.directory?(strDirToZip))
					isWebBuild = false
					strZipFile = File.join(dirBuild, entry + '.zip')
				
					##Use the slug for filename if it's WebGL
					if (entry == game.name + "WebGL" && game.slug != "")
						isWebBuild = true
						strZipFile = File.join(dirBuild, game.slug + '.zip')
					end
				
					puts "Zipping " + strDirToZip + " " + strZipFile
				
					if (File.exist?(strZipFile))
							FileUtils.rm(strZipFile)
					end
				
					zf = ZipFileGenerator.new(strDirToZip, strZipFile)
					zf.write()
				
					if (isWebBuild)
						uploads_dir = File.join($config.projects_dir, "uploads")
						if (!File.directory?(uploads_dir) )
							FileUtils.mkdir(uploads_dir)
						end 

						puts "copying #{strZipFile} to #{uploads_dir}"
						FileUtils.mv(strZipFile, uploads_dir)
					end


				end
			
		
			}

		else
			puts "Skipping, " + dirBuild + " does not exist"

		end
		
	end



end


def clearBuildFolder(games)
	games.each do | game |
		dirProject = File.join($config.projects_dir, game.name)
		dirBuild = File.join($config.projects_dir, game.name, "build")
		puts "Clearing: #{dirBuild}"

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

def deleteVisualStudioProjectFiles(games)
	games.each do | game |
		dirProject = File.join($config.projects_dir, game.name)
#		dirBuild = File.join($config.projects_dir, game.name, "build")
#		puts "Clearing: #{dirBuild}"



		if (File.directory?(dirProject)) 

			Dir.entries(dirProject).select { | strFileName |
				if (strFileName != '.' && strFileName != '..')
					if (strFileName =~ /(.*).csproj/)
						

						filePath = File.join(dirProject, strFileName)
						puts "Deleting: #{filePath}"
						#puts "Deleting " + filePath
						FileUtils.rm_rf(filePath)
					end

					if (strFileName =~ /(.*).sln/)
						

						filePath = File.join(dirProject, strFileName)
						puts "Deleting: #{filePath}"
						FileUtils.rm_rf(filePath)
					end
				
				
			
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
		
#		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -buildWindowsPlayer ' + File.join(dirBuild, game.name + ".exe") + ' -quit'
		strCommand = '"' + $config.getUnityExe() + '" -logFile -projectPath ' + dirProject + ' -buildWindowsPlayer ' + File.join(dirBuild, game.name + ".exe") + ' -quit'
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
		
#		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -buildOSXUniversalPlayer ' + File.join(dirBuild, game.name + ".app") + ' -quit'
		strCommand = '"' + $config.getUnityExe + '" -logFile -projectPath ' + dirProject + ' -buildOSXUniversalPlayer ' + File.join(dirBuild, game.name + ".app") + ' -quit'
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
		
#		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -buildLinuxUniversalPlayer ' + File.join(dirBuild, game.name) + ' -quit'
		strCommand = '"' + $config.getUnityExe() + '" -logFile -projectPath ' + dirProject + ' -buildLinux64Player ' + File.join(dirBuild, game.name) + ' -quit'
		puts strCommand
		system(strCommand)
		
	end
end

def findUnityScenes(games)
	strResult = ""
	games.each do | game |
		dirProject = File.join($config.projects_dir, game.name)
#		dirBuild = File.join($config.projects_dir, game.name, "build")
		puts "Searching: #{dirProject} for Unity scenes"

		if (File.directory?(dirProject)) 

#			Dir.entries(dirProject).select { | strFileName |
#				if (strFileName != '.' && strFileName != '..')
					strResult += game.name + "\n"
#					filePath = File.join(dirProject, strFileName)
					
					unityScenes = Dir.glob(dirProject + "/**/*.unity")
					puts unityScenes
					
					if  (unityScenes.length == 0)
						strResult += "  No Unity Scenes\n"
					else 
						unityScenes.each do | strScene | 
							#strResult += unityScenes.join("\n")
							puts "dirProject: #{dirProject}"
							strResult += "  " + Pathname.new(strScene).relative_path_from(Pathname.new(dirProject)).to_s + "\n"
						end
					
					end
					
					
					
					#strResult += "\n"

				
				
			
#				end
#			}
		end
		
	end
	
	return strResult

end



def displayPackageCache(games)
	strResult = ""
	games.each do | game |
		dirProject = File.join($config.projects_dir, game.name)
		puts "Searching: #{dirProject} for Package Cache"

		strPath = File.join(dirProject, "Library/PackageCache")
		if (File.directory?(dirProject) && File.directory?(strPath)) 
			


			strPackages = ""
			Dir.entries(strPath).select { | strFileName |
				if (strFileName != '.' && strFileName != '..')

					strPackages += "  " + strFileName + "\n"
					
				end
			}
			
			if (strPackages != "")
				strResult += game.name + "\n"
				strResult += strPackages
			
			end
			
		end
		
	end
	
	return strResult

end




def readConfigFile() 
	$config = Config.new
	
	if !File.file?(CONFIG_FILE)
		puts "Could not find unity_verison.config file"
		exit
	end
	
	fileConfig = File.open(CONFIG_FILE, "r")
	
	
	puts "Reading config file"
	if (fileConfig.nil?)
		puts "Could not open unity_verison.config file"
	end
	
	fileConfig.each do | line |

		if (line =~ /UNITY_FOLDER: (.*)/)
			$config.unity_folder = $1
			
			if (File.directory?($config.unity_folder))
				Dir.entries($config.unity_folder).select { | entry |
					if (entry =~ /([0-9]+)\.([0-9]+)\.([0-9]+)([a-z])([0-9]+)/)
						version = UnityVersion.new
						version.versionYear = $1
						version.versionMajor = $2
						version.versionMinor = $3
						version.versionPatch = $4
						version.versionPatchNumber = $5

						puts "Year: #{version.versionYear} Major: #{version.versionMajor} Minor: #{version.versionMinor} Type: #{version.versionPatch} Type Number: #{version.versionPatchNumber}"
						
						if ($config.unity_selected_version.nil?)
							$config.unity_selected_version = version
						elsif ($config.unity_selected_version.versionYear.to_i < version.versionYear.to_i)
							$config.unity_selected_version = version
						elsif ($config.unity_selected_version.versionMajor.to_i < version.versionMajor.to_i)
							$config.unity_selected_version = version
						elsif ($config.unity_selected_version.versionMinor.to_i < version.versionMinor.to_i)
							puts "#{$config.unity_selected_version.versionMinor} < #{version.versionMinor}"
							$config.unity_selected_version = version
						end
					end
				}


				
			end
			
		end

		
		if (line =~ /PROJECTS_DIR: (.*)/)
			$config.projects_dir = $1
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
		
		if (line =~ /COMPANY_NAME: (.*)/)
			$config.company_name = $1
		end

		if (line =~ /BUTLER_EXE: (.*)/)
			$config.butler_exe = $1
		end

		if (line =~ /ITCH_USERNAME: (.*)/)
			$config.itch_username = $1
		end


		
	end
	
	fileConfig.close
	
	if (!File.directory?($config.unity_folder))
		puts "Missing UNITY_FOLDER directory! #{$config.unity_folder}"
		exit
	end

	if (!File.directory?($config.projects_dir))
		puts "Missing PROJECTS_DIR directory! #{$config.projects_dir}"
		exit
	end

	
	if ($config.unity_selected_version.nil?)
		puts "Missing selected Unity version"
	end


end


def getSlugFromConfigFile(strProject) 
	
	strSlug = ""
	
	fileConfig = File.open("slug.config", "r")
	fileConfig.each do | line |
		if (line =~ /(.*)=(.*)/)
		
			if ($1 == strProject)
				strSlug = $2
			end
			
			
		end
		
		
	end
	
	fileConfig.close
	
	return strSlug

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
	f = File.open(CONFIG_FILE, "r")
	f.each do | line |
		if (line =~ /UNITY_CURRENT_VERSION/)
			strConfig << "UNITY_CURRENT_VERSION: " + strVersion + "\n"
		else
			strConfig << line
		end
	end
	f.close()
	
	f = File.open(CONFIG_FILE, "w")
	f.puts strConfig
	f.close()

end

def removeDefaultPackages(games)
	games.each do | game |
		puts "Removing default packages: #{game.name}"
		dirProject = File.join($config.projects_dir, game.name)


		if (!File.directory?(File.join(dirProject, "Assets/Editor")) )
			FileUtils.mkdir(File.join(dirProject, "Assets/Editor"))
		end 

		FileUtils.cp("PackageRemover.cs.template", File.join(dirProject, "Assets/Editor/PackageRemover.cs"))

#		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -executeMethod PackageRemover.RemovePackages -quit'
		strCommand = '"' + $config.getUnityExe() + '" -logFile -projectPath ' + dirProject + ' -executeMethod PackageRemover.RemovePackages -quit'
		puts strCommand
		system(strCommand)
	end


end

def updateProjectSettings(games)
	games.each do | game |
		puts "Updating project settings: #{game.name}"
		dirProject = File.join($config.projects_dir, game.name)


		if (!File.directory?(File.join(dirProject, "Assets/Editor")) )
			FileUtils.mkdir(File.join(dirProject, "Assets/Editor"))
		end 

		strFileContents = ""
		fTempFile = File.open("UpdateProjectSettings.cs.template", "r")
		fTempFile.each do | line |
			if (line =~ /(.*)(%NAME%)(.*)/)
				strFileContents << $1 << $config.company_name << $3 << "\n"
			else 
				strFileContents << line
			end
		end
		fTempFile.close


#		FileUtils.cp("UpdateProjectSettings.cs.template", File.join(dirProject, "Assets/Editor/UpdateProjectSettings.cs"))


		File.open(File.join(dirProject, "Assets/Editor/UpdateProjectSettings.cs"), 'w') { | file |
			file.write(strFileContents)
		
		}

#		strCommand = '"' + $config.unity_exe + '" -logFile -projectPath ' + dirProject + ' -executeMethod UpdateProjectSettings.UpdateSettings -quit'
		strCommand = '"' + $config.getUnityExe() + '" -logFile -projectPath ' + dirProject + ' -executeMethod UpdateProjectSettings.UpdateSettings -quit'
		puts strCommand
		system(strCommand)
	end


end



def updateAPI(games)
	games.each do | game |
		puts "Updating API: #{game.name}"
		dirProject = File.join($config.projects_dir, game.name)

#		FileUtils.cp("PackageRemover.cs.template", File.join(dirProject, "Assets/Editor/PackageRemover.cs"))

#		strCommand = '"' + $config.unity_exe + '" -accept-apiupdate -batchmode -quit -projectPath ' + dirProject
		strCommand = '"' + $config.getUnityExe() + '" -accept-apiupdate -batchmode -quit -projectPath ' + dirProject
		puts strCommand
		system(strCommand)
	end


end

def deleteObsoleteScripts(games)
	games.each do | game |
		dirProject = File.join($config.projects_dir, game.name)

		if (File.directory?(dirProject)) 

#			Dir.entries(dirProject).select { | strFileName |
#				if (strFileName != '.' && strFileName != '..')

#					if (strFileName =~ /build_all.bat/)
					strFileName = "build_all.bat"
					filePath = File.join(dirProject, strFileName)
					
					if (File.file?(filePath))
						puts "Deleting: #{filePath}"
						FileUtils.rm_rf(filePath)
					end

#					if (strFileName =~ /Assets/Editor/MyEditorScript.cs/)
						

#						filePath = File.join(dirProject, strFileName)
					strFileName = "Assets/Editor/MyEditorScript.cs"
					filePath = File.join(dirProject, strFileName)
					if (File.file?(filePath))
						puts "Deleting: #{filePath}"
						FileUtils.rm_rf(filePath)
					end
				
				
			
#				end
#			}
		end
		
	end

end





def makeUploadScript(game, strProjectIdentifier)
	makeItchUploadScript(game.name, strProjectIdentifier, $config.projects_dir)

end

def callUploadScript(games)
	dirOrig = Dir.pwd
	games.each do | game |
		dirProject = File.join($config.projects_dir, game.name)


#		if (File.directory?(dirProject)) 
#			strFile = File.join(dirProject, "butler_push_all.bat")
#			Dir.chdir dirProject
#			if (File.file?(strFile))
#				puts strFile
#				system(strFile)
#			end
#		end
		strCommand = $config.butler_exe + ' push ' + File.join(dirProject, 'build', game.name + 'Windows') + ' ' + $config.itch_username + '/' + game.slug + ':win'
		puts "calling butler upload for Windows: #{strCommand}"
		system(strCommand)

		strCommand = $config.butler_exe + ' push ' + File.join(dirProject, 'build', game.name + 'Mac') + ' ' + $config.itch_username + '/' + game.slug + ':osx'		
		puts "calling butler upload for Mac: #{strCommand}"
		system(strCommand)

		strCommand = $config.butler_exe + ' push ' + File.join(dirProject, 'build', game.name + 'Linux') + ' ' + $config.itch_username + '/' + game.slug + ':linux'		
		puts "calling butler upload for Linux: #{strCommand}"
		system(strCommand)


	

	end
	
	Dir.chdir dirOrig

end

def addSlug(game, strSlug)
	fileSlugOriginal = File.open("slug.config", "r")
	strSlugOriginal = fileSlugOriginal.readlines()
	fileSlugOriginal.close()
#	strSlugConfigOriginal = File.readlines("slug.config")

	strSlugConfig = ""
	slugUpdated = false

	strSlugOriginal.each do | line |
		if (line =~ /(.*)=(.*)/)
			if ($1 == game.name)
				if (!slugUpdated)
					strSlugConfig += game.name + "=" + strSlug + "\n"
					slugUpdated = true
				end
			else
				strSlugConfig += line
			end
		end
	
	end
	
	if (!slugUpdated)
		strSlugConfig += "\n" + game.name + "=" + strSlug
	end

	strArray = strSlugConfig.split("\n")
	strArray.sort!
	strSlugConfig = strArray.join("\n")
	
	puts "writing file: " + strSlugConfig

	fileSlugConfig = File.open("slug.config", "w")
	fileSlugConfig.write(strSlugConfig)
	fileSlugConfig.close




end


def ignoreProjects(games)
	games.each do | game |
	
		fileIgnore = File.open(IGNORE_FILE, "a")
		fileIgnore.puts game.name
		fileIgnore.close
		
	

	end

end

def fixScriptTemplate()

	puts "current unity version: " + $config.unity_selected_version.ToString()
#	puts "current unity version: " + $config.unity_current_version

	strTemplateFile = $config.unity_folder + '/' + $config.unity_selected_version.ToString() + '/Editor/Data/Resources/ScriptTemplates/81-C# Script-NewBehaviourScript.cs.txt'
	f = File.open("script_template.txt")
	strTemplate = f.read()
	f.close()
	
	strTemplate.gsub!("<year>", Time.now.strftime("%Y"))
	strTemplate.gsub!("<author>", $config.company_name)
	
	puts "Updating file: #{strTemplateFile}"
	puts "New contents:\n#{strTemplate}"

	f = File.open(strTemplateFile, "w")
	f.write(strTemplate)
	f.close()



end



def main()
	readConfigFile
	displayProjects()
end
