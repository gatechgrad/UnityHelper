### 2018, 2019, 2020, 2022 Levi D. Smith
### levidsmith.com

require 'gtk3'
require 'win32/sound'
include Win32
require_relative 'unity_version'

PLAYMAKER_INSTALL_PACKAGE = 'playmaker\Playmaker.1.9.5.unitypackage'

$tableGames = Gtk::Table.new(1, 1, false)
$checkboxArray
$labelArray
$gameArray


def tableRemoveAll()

	$tableGames.children.each do | child |
		$tableGames.remove(child)
	end

end


def makeGameProjectHeaders()
	headerBkgColor = Gdk::RGBA::new(  0.8, 0.8, 0.8, 1.0)

	checkboxAll = Gtk::CheckButton.new()
	checkboxAll.expand = false
	checkboxAll.width_request = 64
	$tableGames.attach(checkboxAll, 0, 1, 0, 1, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 0, 0)
	checkboxAll.show
	checkboxAll.signal_connect "clicked" do |_widget|
		
		toggleAllCheckboxes(_widget.active?)
	
	end
	checkboxAll.override_background_color(:normal, headerBkgColor)



	labelName = Gtk::Label.new("Project Name")
	labelName.override_background_color(:normal, headerBkgColor)
	$tableGames.attach_defaults(labelName, 1, 2, 0, 1)
	labelName.show

	labelSlug = Gtk::Label.new("Slug")
	labelSlug.override_background_color(:normal, headerBkgColor)
	$tableGames.attach_defaults(labelSlug, 2, 3, 0, 1)
	labelSlug.show


	labelUnityVersion = Gtk::Label.new("Unity Version")
	labelUnityVersion.override_background_color(:normal, headerBkgColor)
	$tableGames.attach_defaults(labelUnityVersion, 3, 4, 0, 1)
	labelUnityVersion.show
	
	labelPlayMakerVersion = Gtk::Label.new("PlayMaker Version")
	labelPlayMakerVersion.override_background_color(:normal, headerBkgColor)
	$tableGames.attach_defaults(labelPlayMakerVersion, 4, 5, 0, 1)
	labelPlayMakerVersion.show
	
	$tableGames.set_row_spacing(0, 8)


end


def makePlatformCompilePanel()

	$platformCheckbox = Hash.new 


	panel = Gtk::Box.new(:vertical, 2)

	

#Windows Checkbox
	panelRow = Gtk::Box.new(:horizontal, 2)
	checkboxWindows = Gtk::CheckButton.new()
	checkboxWindows.width_request = 64
	checkboxWindows.expand = false
	checkboxWindows.active = true
	checkboxWindows.show
	$platformCheckbox["Windows"] = checkboxWindows
	panelRow.add(checkboxWindows)

	labelWindows = Gtk::Label.new("Windows")
	labelWindows.expand = true
	labelWindows.set_alignment(0, 0.5)
	panelRow.add(labelWindows)
	
	panel.add(panelRow)


#Mac Checkbox
	panelRow = Gtk::Box.new(:horizontal, 2)
	checkboxMac = Gtk::CheckButton.new()
	checkboxMac.width_request = 64
	checkboxMac.expand = false
	checkboxMac.active = true
	checkboxMac.show
	$platformCheckbox["Mac"] = checkboxMac
	panelRow.add(checkboxMac)

	labelMac = Gtk::Label.new("Mac")
	labelMac.expand = true
	labelMac.set_alignment(0, 0.5)
	panelRow.add(labelMac)
	
	panel.add(panelRow)
	

#Linux Checkbox
	panelRow = Gtk::Box.new(:horizontal, 2)
	checkboxLinux = Gtk::CheckButton.new()
	checkboxLinux.width_request = 64
	checkboxLinux.expand = false
	checkboxLinux.active = true	
	checkboxLinux.show
	$platformCheckbox["Linux"] = checkboxLinux
	panelRow.add(checkboxLinux)

	labelLinux = Gtk::Label.new("Linux")
	labelLinux.expand = true
	labelLinux.set_alignment(0, 0.5)
	panelRow.add(labelLinux)
	
	panel.add(panelRow)


#WebGL Checkbox
	panelRow = Gtk::Box.new(:horizontal, 2)
	checkboxWebgl = Gtk::CheckButton.new()
	checkboxWebgl.width_request = 64
	checkboxWebgl.expand = false
	checkboxWebgl.active = false
	checkboxWebgl.show
	$platformCheckbox["WebGL"] = checkboxWebgl
	panelRow.add(checkboxWebgl)

	labelWebgl = Gtk::Label.new("WebGL")
	labelWebgl.expand = true
	labelWebgl.set_alignment(0, 0.5)
	panelRow.add(labelWebgl)
	
	panel.add(panelRow)

	
#Make ZIP files Checkbox
	panelRow = Gtk::Box.new(:horizontal, 2)
	checkboxMakeZip = Gtk::CheckButton.new()
	checkboxMakeZip.width_request = 64
	checkboxMakeZip.expand = false
	checkboxMakeZip.active = true
	checkboxMakeZip.show
	$platformCheckbox["MakeZip"] = checkboxMakeZip
	panelRow.add(checkboxMakeZip)

	labelMakeZip = Gtk::Label.new("Make ZIP files")
	labelMakeZip.expand = true
	labelMakeZip.set_alignment(0, 0.5)
	panelRow.add(labelMakeZip)
	
	panel.add(panelRow)
	

	button = Gtk::Button.new(:label => "Compile Selected")
	button.signal_connect "clicked" do |_widget|
		compileClicked()
	end
	panel.add(button)

	
	return(panel)


end

def makeGameProjectRow(iRow, gameProject)

	
	gameCheckbox = Gtk::CheckButton.new()
	gameCheckbox.signal_connect "clicked" do |_widget|
		puts "clicked #{$gameArray[iRow - 1].name}"
		if (_widget.active?) 
			selectedColor = Gdk::RGBA::new(  0.8, 0.8, 1.0, 1.0);
		else 
			selectedColor = Gdk::RGBA::new(  0.9, 0.9, 0.9, 1.0);
		end
		$labelArray[iRow - 1].override_background_color(:normal, selectedColor)

	end

	$checkboxArray << gameCheckbox

	$tableGames.attach(gameCheckbox, 0, 1, iRow, iRow + 1, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 0, 0)


	gameCheckbox.width_request = 64
	gameCheckbox.expand = false
	gameCheckbox.show

## Project Name
	labelName = Gtk::Label.new(gameProject.name)
	labelName.expand = true
	labelName.set_alignment(0, 0.5)
	$labelArray << labelName
	
	$gameArray << gameProject
	$tableGames.attach_defaults(labelName, 1, 2, iRow, iRow + 1)
	labelName.show

## Slug
	labelSlug = Gtk::Label.new(gameProject.slug)
	labelSlug.expand = true
	labelSlug.set_alignment(0, 0.5)
#	$labelArray << labelName
	
#	$gameArray << gameProject
	$tableGames.attach_defaults(labelSlug, 2, 3, iRow, iRow + 1)
	labelSlug.show



## Project Version	
	labelVersion = Gtk::Label.new("")
	isCurrentMajorVersion = true
	isCurrentMinorVersion = true
	isCurrentPatchVersion = true
	
	versionNumbers = Array.new
	gameProject.versions.each do | version |
		versionNumbers << version.versionNumber
	end
	
	versionNumbers.uniq.each do | vn |
		if (labelVersion.label != "")
			labelVersion.label += ", "
		end
		
#		vnMajorMinor = vn.split('.')
#		unityMajorMinor = $config.unity_current_version.split('.')
		if (vn =~ /([0-9]+)\.([0-9]+)\.([0-9]+)([a-z])([0-9]+)/)
			vnYear = $1
			vnMajor = $2
			vnMinor = $3
			vnPatch = $4
			vnPatchNumber = $5

		
	#		if (vnMajorMinor[0] != unityMajorMinor[0] || vnMajorMinor[1] != unityMajorMinor[1])
			if (vnYear != $config.unity_selected_version.versionYear || vnMajor != $config.unity_selected_version.versionMajor)
#				puts "#{gameProject.name} compare year #{vnYear} != #{$config.unity_selected_version.versionYear}, major #{vnMajor} = #{$config.unity_selected_version.versionMajor} "
				isCurrentMajorVersion = false
	#		elsif (vnMajorMinor[2] != unityMajorMinor[2])
			elsif (vnMinor != $config.unity_selected_version.versionMinor)
#				puts "#{gameProject.name} compare minor #{vnMinor} != #{$config.unity_selected_version.versionMinor} "
				isCurrentMinorVersion = false
			elsif (vnPatch != $config.unity_selected_version.versionPatch || vnPatchNumber != $config.unity_selected_version.versionPatchNumber)
				isCurrentPatchVersion = false
			end
		
		end
		labelVersion.label += "#{vn}"
	end
	
	#check each version
	
	if (!isCurrentMajorVersion)
		labelVersion.override_background_color(:normal, Gdk::RGBA::new(  1.0, 0.5, 0.5, 1.0))
	elsif (!isCurrentMinorVersion)
		labelVersion.override_background_color(:normal, Gdk::RGBA::new(  1.0, 0.75, 0.5, 1.0))
	elsif (!isCurrentPatchVersion)
		labelVersion.override_background_color(:normal, Gdk::RGBA::new(  1.0, 1.0, 0.5, 1.0))
	end
	$tableGames.attach_defaults(labelVersion, 3, 4, iRow, iRow + 1)
	labelVersion.show


## PlayMaker version
	labelPlaymakerVersion = Gtk::Label.new("")
	if (!gameProject.playmaker_version.nil? )
		labelPlaymakerVersion.label = gameProject.playmaker_version
		
		if (labelPlaymakerVersion.label != $config.playmaker_current_version) 
			labelPlaymakerVersion.override_background_color(:normal, Gdk::RGBA::new(  1.0, 0.5, 0.5, 1.0))
		end

		
	end
	$tableGames.attach_defaults(labelPlaymakerVersion, 4, 5, iRow, iRow + 1)
	labelPlaymakerVersion.show
	
	
	$tableGames.set_row_spacing(iRow, 8)

	
	
end


def makeWindow()
	window = Gtk::Window.new("Unity Version")
	window.set_size_request(640, 480)
	window.set_border_width(10)


	iRow = 0

	grid = Gtk::Grid.new
	$gridGames = Gtk::Grid.new
	$gridGames.column_homogeneous = false


	textResults = Gtk::TextView.new()
	scrolledWindow = Gtk::ScrolledWindow.new()

	labelProjectDirectory = Gtk::Label.new
	labelProjectDirectory.label = "Projects Directory"
	grid.attach(labelProjectDirectory, 0, iRow, 1, 1)

	$textProjectDirectory = Gtk::Entry.new
	$textProjectDirectory.editable = false
	$textProjectDirectory.text = $config.projects_dir
	grid.attach($textProjectDirectory, 1, iRow, 1, 1)

	iRow += 1

	labelUnityFolder = Gtk::Label.new
	labelUnityFolder.label = "Unity Folder"
	grid.attach(labelUnityFolder, 0, iRow, 1, 1)

	$textUnityFolder = Gtk::Entry.new
	$textUnityFolder.editable = false
	$textUnityFolder.text = $config.unity_folder
	grid.attach($textUnityFolder, 1, iRow, 1, 1)
	
	iRow += 1

	labelProjectDirectory = Gtk::Label.new
	labelProjectDirectory.label = "Unity Current Version"
	grid.attach(labelProjectDirectory, 0, iRow, 1, 1)

	$textUnityCurrentVersion = Gtk::Entry.new
	$textUnityCurrentVersion.editable = false
	$textUnityCurrentVersion.text = $config.unity_selected_version.ToString()
	grid.attach($textUnityCurrentVersion, 1, iRow, 1, 1)
	
	iRow += 1


	labelUnityExecutable = Gtk::Label.new
	labelUnityExecutable.label = "Unity Executable"
	grid.attach(labelUnityExecutable, 0, iRow, 1, 1)
	
	$textUnityExecutable = Gtk::Entry.new
	$textUnityExecutable.editable = false
#	$textUnityExecutable.text = $config.unity_exe
	$textUnityExecutable.text = $config.getUnityExe()
	grid.attach($textUnityExecutable, 1, iRow, 1, 1)
	
	iRow += 1


	puts "Adding new table row"
	window.set_title("Unity Build Tool - 2022 Levi D. Smith")



	buttonBox = Gtk::ButtonBox.new(:horizontal)
	buttonBox.add(makePlatformCompilePanel())

## Scan Projects button
	scanBox = Gtk::ButtonBox.new(:vertical)
	
	button = Gtk::Button.new(:label => "Scan Projects")
	button.signal_connect "clicked" do |_widget|
		scanProjects()
	end
	scanBox.add(button)

## Find Unity Scenes
	button = Gtk::Button.new(:label => "Find Unity Scenes")
	button.signal_connect "clicked" do |_widget|
		findUnityScenesClicked()
	end
	scanBox.add(button)


## Enter slug
	button = Gtk::Button.new(:label => "Enter Slug")
	button.signal_connect "clicked" do |_widget|
		enterSlugClicked()
	end
	scanBox.add(button)


## Ignore project
	button = Gtk::Button.new(:label => "Ignore")
	button.signal_connect "clicked" do |_widget|
		ignoreClicked()
	end
	scanBox.add(button)

## Edit config
	button = Gtk::Button.new(:label => "Edit Config")
	button.signal_connect "clicked" do |_widget|
		editConfigClicked()
	end
	scanBox.add(button)



	buttonBox.add(scanBox)


## Make build box
	buildBox = Gtk::ButtonBox.new(:vertical)
	
##Clear build folder button
	button = Gtk::Button.new(:label => "Clear build folder")
	button.signal_connect "clicked" do |_widget|
		clearBuildFolderClicked()
	end
	buildBox.add(button)


##Open build folder
	button = Gtk::Button.new(:label => "Open build folder")
	button.signal_connect "clicked" do |_widget|
		openBuildFolderClicked()
	end
	buildBox.add(button)
	
#	buttonBox.add(buildBox)


##Clear VS project files
	button = Gtk::Button.new(:label => "Clear VS files")
	button.signal_connect "clicked" do |_widget|
		clearVSFilesClicked()
	end
	buildBox.add(button)

##Remove default packages
	button = Gtk::Button.new(:label => "Remove Default Packages")
	button.signal_connect "clicked" do |_widget|
		removeDefaultPackagesClicked()
	end
	buildBox.add(button)

##Delete non source folders (Library, Temp, Logs)
	button = Gtk::Button.new(:label => "Delete Non Source folders")
	button.signal_connect "clicked" do |_widget|
		deleteNonSourceFoldersClicked()
	end
	buildBox.add(button)


##Update API
	button = Gtk::Button.new(:label => "Update API")
	button.signal_connect "clicked" do |_widget|
		updateAPIClicked()
	end
	buildBox.add(button)

##Update Project Settings
	button = Gtk::Button.new(:label => "Update Project Settings")
	button.signal_connect "clicked" do |_widget|
		updateProjectSettingsClicked()
	end
	buildBox.add(button)


##Delete Obsolete Scripts
	button = Gtk::Button.new(:label => "Delete Obsolete Scripts")
	button.signal_connect "clicked" do |_widget|
		deleteObsoleteScriptsClicked()
	end
	buildBox.add(button)


##Display package cache
	button = Gtk::Button.new(:label => "Display Package Cache")
	button.signal_connect "clicked" do |_widget|
		displayPackageCacheClicked()
	end
	buildBox.add(button)

##Fix script template
	button = Gtk::Button.new(:label => "Fix script template")
	button.signal_connect "clicked" do |_widget|
		fixScriptTemplate()
	end
	buildBox.add(button)


	
	buttonBox.add(buildBox)


##Make utilities box
	utilitiesBox = Gtk::ButtonBox.new(:vertical)
	
	#Export PlayMaker globals
	button = Gtk::Button.new(:label => "Export PlayMaker globals")
	button.signal_connect "clicked" do |_widget|
		exportPlaymakerGlobalsClicked()
	end
	utilitiesBox.add(button)


	#Install New PlayMaker
	button = Gtk::Button.new(:label => "Install New PlayMaker")
	button.signal_connect "clicked" do |_widget|
		installNewPlayMakerClicked()
	end
	utilitiesBox.add(button)


	buttonBox.add(utilitiesBox)



##Scan Unity version button
#	button = Gtk::Button.new(:label => "Scan Unity Version")
#	button.signal_connect "clicked" do |_widget|
#		scanUnityVersion()
#	end
#	buttonBox.add(button)



## Make upload box
	uploadBox = Gtk::ButtonBox.new(:vertical)


##Copy scripts to project
	button = Gtk::Button.new(:label => "Copy scripts and splash images", :tooltip => "hello")
	button.signal_connect "clicked" do |_widget|
		copyScriptsClicked()
	end
	uploadBox.add(button)


## Make Upload Script button - obsolete, butler executed directly from the script
#	button = Gtk::Button.new(:label => "Make Upload Script")
#	button.signal_connect "clicked" do |_widget|
#		makeUploadScriptAllSelected()
#	end
#	uploadBox.add(button)

	
## Call Upload Script button	
	button = Gtk::Button.new(:label => "Call Upload Script")
	button.signal_connect "clicked" do |_widget|
		callUploadScriptClicked()
	end
	uploadBox.add(button)



## Online Docs
	button = Gtk::Button.new(:label => "Online Docs")
	button.signal_connect "clicked" do |_widget|
		onlineDocsClicked()
	end
	uploadBox.add(button)
	
	buttonBox.add(uploadBox)

## Quit button	
#	button = Gtk::Button.new(:label => "Quit")
#	button.signal_connect "clicked" do |_widget|
#		Gtk.main_quit
#	end
#   buttonBox.add(button)


	grid.attach(buttonBox, 0, iRow, 2, 1)
	iRow += 1


	textResults.buffer.text = 'Hello'
	scrolledWindow.min_content_width = 1200
#	scrolledWindow.min_content_height = 600
	scrolledWindow.min_content_height = 400
	scrolledWindow.vscrollbar_policy = Gtk::PolicyType::ALWAYS


	scrolledWindow.add($tableGames)
	grid.attach(scrolledWindow, 0, iRow, 2, 1)



	window.add(grid)
	window.signal_connect("delete-event") { |_widget| Gtk.main_quit }
	window.show_all
	
	$mainWindow = window

end


def scanProjects() 
		puts "Check"
		tableRemoveAll()
		gameProjectsList = displayProjects($textProjectDirectory.text, $textUnityCurrentVersion.text)
	
		makeGameProjectHeaders()
	
		iGame = 1
	
		$checkboxArray = Array.new
		$gameArray = Array.new
		$labelArray = Array.new


		if (!gameProjectsList.nil?)
			gameProjectsList.each do | game |
	
				makeGameProjectRow(iGame, game)
				iGame += 1
			end
		end

end

def compileClicked() 

	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			if ($platformCheckbox["Windows"].active?)
				compileWindows(selectedArray)
			end
		
			if ($platformCheckbox["Mac"].active?)
				compileMac(selectedArray)
			end

			if ($platformCheckbox["Linux"].active?)
				compileLinux(selectedArray)
			end
		
			if ($platformCheckbox["WebGL"].active?)
				compileWebGL(selectedArray)
			end
		
			if ($platformCheckbox["MakeZip"].active?)
				makeZipFiles(selectedArray)
			end
		
			Sound.play('.\sounds\jobsdone.wav')

			displayInfoDialog("Tasks completed")
		
		else
			displayInfoDialog("No projects selected")
		
		end 

		

		
		
	else
		puts "No games selected"
	end

end

def makeUploadScriptAllSelected() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end

		if (selectedArray.length > 0)
			selectedArray.each do | game |
		
				puts "Make upload script for " + game.name
				strProjectIdentifier = ""

				if (game.slug != "")
					strProjectIdentifier = game.slug

				else 
					md = Gtk::MessageDialog.new :parent => $mainWindow,
					:flags => :destroy_with_parent, :type => :question,
					:buttons_type => :ok, :message => "Enter Itch.io identifier for\n" + game.name
					entry = Gtk::Entry.new
					md.child.add(entry)
					md.show_all()
					md.run()

					strProjectIdentifier = entry.text
					md.destroy()

				end

			
			
				if (strProjectIdentifier != "")
					makeUploadScript(game, strProjectIdentifier)

			

				end

			end
		
			Sound.play('.\sounds\jobsdone.wav')
		
		else
			displayInfoDialog("No projects selected")
		
		end

		

		
		
		
	end



end


def toggleAllCheckboxes(checked) 
	if (checked)
		puts "Check all"
	else
		puts "Uncheck all"
	
	end
	
	$checkboxArray.each do | checkbox |
		checkbox.active = checked
	end

	
end

def clearBuildFolderClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			clearBuildFolder(selectedArray)
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		
	else
		puts "No games selected"
	end
end

def clearVSFilesClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			deleteVisualStudioProjectFiles(selectedArray)
		
			Sound.play('.\sounds\jobsdone.wav')
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		

		
	else
		puts "No games selected"
	end
end


def openBuildFolderClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			selectedArray.each do | game |
				dirProject = File.join($config.projects_dir, game.name)
				strPath = File.join(dirProject, "build").gsub(File::SEPARATOR, File::ALT_SEPARATOR)
				puts "Opening folder #{strPath}"
			##  Only Windows Explorer for now

				if (!Dir.exist?(strPath))
					FileUtils.mkdir_p(strPath)
				end


				strCommand = 'explorer %s' % strPath
				system('explorer %s' % strPath)
		
			end
		
		else
			displayInfoDialog("No projects selected")
		
		end
		
		

		
	else
		puts "No games selected"


	end


end


def copyScriptsClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			copyAutoSaveScript(selectedArray)

			Sound.play('.\sounds\jobsdone.wav')
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		
		
		
	else
		puts "No games selected"
	end


end

def removeDefaultPackagesClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			removeDefaultPackages(selectedArray)

			Sound.play('.\sounds\jobsdone.wav')
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		

	else
		puts "No games selected"
	end


end

def deleteNonSourceFoldersClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			deleteNonSourceFolders(selectedArray)

			Sound.play('.\sounds\jobsdone.wav')
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		

	else
		puts "No projects selected"
	end


end



def updateAPIClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			updateAPI(selectedArray)
		
			Sound.play('.\sounds\jobsdone.wav')
		
		else
			displayInfoDialog("No projects selected")
		
		end 		
		

	else
		puts "No games selected"
	end


end


def deleteObsoleteScriptsClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			deleteObsoleteScripts(selectedArray)
		
			Sound.play('.\sounds\jobsdone.wav')
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		

	else
		puts "No games selected"
	end


end


def updateProjectSettingsClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			updateProjectSettings(selectedArray)
		
			Sound.play('.\sounds\jobsdone.wav')
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		

	else
		puts "No games selected"
	end


end

def callUploadScriptClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			callUploadScript(selectedArray)
		
			Sound.play('.\sounds\jobsdone.wav')
		
		else
			displayInfoDialog("No projects selected")
		
		end 

		

	else
		puts "No games selected"
	end


end




def findUnityScenesClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			strResult = findUnityScenes(selectedArray)

			displayInfoDialog("Unity scenes\n" + strResult)
		
		
			#md = Gtk::MessageDialog.new :parent => $mainWindow,
#				:flags => :destroy_with_parent, :type => :info,
#				:buttons_type => :close, :message => "Unity scenes\n" + strResult
			#md.run
			#md.destroy
		
		else
			displayInfoDialog("No projects selected")
		
		end 

		

		
	else
		puts "No games selected"
	end

end

def enterSlugClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			selectedArray.each do | game |
		
				strSlug = ""

				md = Gtk::MessageDialog.new :parent => $mainWindow,
					:flags => :destroy_with_parent, :type => :question,
					:buttons_type => :ok, :message => "Enter slug for \n" + game.name
				entry = Gtk::Entry.new
				md.child.add(entry)
				md.show_all()
				md.run()

				strSlug = entry.text
			
				md.destroy()
			
				if (strSlug != "")
					addSlug(game, strSlug)
			

				end

			end
		
			scanProjects()
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		
	else
		puts "No games selected"
	end

end


def exportPlaymakerGlobalsClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			selectedArray.each do | game |
			
				if (game.playmaker_version != "")


					dirProject = File.join($config.projects_dir, game.name)
					exportPlaymakerGlobals(dirProject)



				end
		

			end
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		
	else
		puts "No games selected"
	end

end

def exportPlaymakerGlobals(dirProject)
					strPath = File.join(dirProject, "export").gsub(File::SEPARATOR, File::ALT_SEPARATOR)
					puts "Opening folder #{strPath}"

					if (!Dir.exist?(strPath))
						FileUtils.mkdir_p(strPath)
					end
					
					strGlobals = File.join(dirProject, "Assets", "PlayMaker", "Resources", "PlayMakerGlobals.asset")
					
					if (File.exist?(strGlobals))
						puts "Exporting PlayMakerGlobals.asset to export directory"
						FileUtils.cp(strGlobals, strPath)
					else 
						puts "PlayMakerGlobals.asset does not exist"
					end

end


def installNewPlayMakerClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			selectedArray.each do | game |
			
				if (game.playmaker_version != "")


					dirProject = File.join($config.projects_dir, game.name)
					
					puts "exporting Playmaker globals"
					exportPlaymakerGlobals(dirProject)

					strPath = File.join(dirProject, "Assets", "PlayMaker")
					if (Dir.exist?(strPath))
						puts "Deleting #{strPath}"
						FileUtils.rm_rf(strPath)
					end

					strPath = File.join(dirProject, "Assets", "Gizmos")
					if (Dir.exist?(strPath))
						puts "Deleting #{strPath}"
						FileUtils.rm_rf(strPath)
					end
					

					strPath = File.join(dirProject, "Assets", "Plugins", "PlayMaker")
					if (Dir.exist?(strPath))
						puts "Deleting #{strPath}"
						FileUtils.rm_rf(strPath)
					end

					strPath = File.join(dirProject, "Assets", "Plugins", "PlayMaker.meta")
					if (!Dir.exist?(strPath))
						puts "Deleting #{strPath}"
						FileUtils.rm_rf(strPath)
					end
					
					#strPlayMakerDefault = 'D:\ldsmith\projects\KittysAdventure\Assets\PlayMaker\Versions\PlaymakerDefault.unitypackage'
					#FileUtils.cp(strPlayMakerDefault, dirProject + '\Assets')
#		strCommand = '"' + $config.getUnityExe() + '" -logFile -projectPath ' + dirProject + ' -importPackage D:\ldsmith\projects\KittysAdventure\Assets\PlayMaker\Versions\PlaymakerDefault.unitypackage -quit'
#		puts strCommand
		#system(strCommand)
					puts "Copying new Playmaker"
					FileUtils.mkdir(File.join(dirProject, "Assets", "PlayMaker"))
#					FileUtils.cp('playmaker\Playmaker.1.9.0.unitypackage', File.join(dirProject, "Assets", "PlayMaker"))
					FileUtils.cp(PLAYMAKER_INSTALL_PACKAGE, File.join(dirProject, "Assets", "PlayMaker"))
					

					
					displayInfoDialog("Open the project in Unity and run Assets/#{PLAYMAKER_INSTALL_PACKAGE}\nImport\nFix any remaining errors (remove UnityHelper scripts)\nUnity menu should display.  Don't install again\nImport Globals by copying <project folder>/export/PlaymakerGlobals.asset to Assets/Playmaker/Resources\nRestart project in Unity")

				end
		

			end
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		
	else
		puts "No games selected"
	end

end




def displayPackageCacheClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			strResult = displayPackageCache(selectedArray)
		
			md = Gtk::Dialog.new(:title => "Package Contents", :parent => $mainWindow, :flags => :destroy_with_parent, :buttons_type => :close)

			labelResult = Gtk::Label.new(strResult)
				
			scrolledPackageWindow = Gtk::ScrolledWindow.new()
			scrolledPackageWindow.min_content_width = 400
			scrolledPackageWindow.min_content_height = 600
			scrolledPackageWindow.vscrollbar_policy = Gtk::PolicyType::ALWAYS
			scrolledPackageWindow.add(labelResult)

			md.set_size_request(400, 480)

			md.child.add(scrolledPackageWindow)


			md.show_all()

			md.run
			md.destroy
		
		else
			displayInfoDialog("No projects selected")
		
		end 

		

		
	else
		puts "No games selected"
	end

end


def ignoreClicked() 
	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		if (selectedArray.length > 0)
			ignoreProjects(selectedArray)
			scanProjects()
		
		else
			displayInfoDialog("No projects selected")
		
		end 
		
		

	else
		puts "No games selected"
	end

end


def editConfigClicked()

	strCommand = "notepad " + CONFIG_FILE
	system(strCommand)

end

def onlineDocsClicked() 
			strCommand = 'explorer %s' % "https://levidsmith.com/wiki/Unity_Build_Tool"
			system(strCommand)

end


#def scanUnityVersion() 
#			getUnityVersion()
#			readConfigFile()
#			$textUnityCurrentVersion.text = $config.unity_current_version
#			$textUnityCurrentVersion.text = "foo"
#end


def displayInfoDialog(strMessage)

				md = Gtk::MessageDialog.new :parent => $mainWindow,
				:flags => :destroy_with_parent, :type => :question,
				:buttons_type => :ok, :message => strMessage
				md.run()
				md.destroy()


end



#GUI Startup
readConfigFile()
makeWindow()
if ($config.scan_projects_on_startup)
	puts "scanning projects"
	scanProjects()
end

Gtk.main