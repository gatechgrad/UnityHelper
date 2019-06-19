### 2018, 2019 Levi D. Smith
### levidsmith.com

require 'gtk3'
require_relative 'unity_version'

$tableGames = Gtk::Table.new(1, 1, false)
$checkboxArray
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

	labelUnityVersion = Gtk::Label.new("Unity Version")
	labelUnityVersion.override_background_color(:normal, headerBkgColor)
	$tableGames.attach_defaults(labelUnityVersion, 2, 3, 0, 1)
	labelUnityVersion.show
	
	labelPlayMakerVersion = Gtk::Label.new("PlayMaker Version")
	labelPlayMakerVersion.override_background_color(:normal, headerBkgColor)
	$tableGames.attach_defaults(labelPlayMakerVersion, 3, 4, 0, 1)
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
	$checkboxArray << gameCheckbox

	$tableGames.attach(gameCheckbox, 0, 1, iRow, iRow + 1, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 0, 0)


	gameCheckbox.width_request = 64
	gameCheckbox.expand = false
	gameCheckbox.show

	labelName = Gtk::Label.new(gameProject.name)
	labelName.expand = true
	labelName.set_alignment(0, 0.5)
#	labelName.override_background_color(:normal, Gdk::RGBA::new(  1.0, 1.0, 1.0, 1.0))
	
	$gameArray << gameProject
	$tableGames.attach_defaults(labelName, 1, 2, iRow, iRow + 1)
	labelName.show
	
	labelVersion = Gtk::Label.new("")
	isCurrentMajorVersion = true
	isCurrentMinorVersion = true
	isCurrentMinorMinorVersion = true
	
	versionNumbers = Array.new
	gameProject.versions.each do | version |
		versionNumbers << version.versionNumber
	end
	
	versionNumbers.uniq.each do | vn |
		if (labelVersion.label != "")
			labelVersion.label += ", "
		end
		
		vnMajorMinor = vn.split('.')
		unityMajorMinor = $config.unity_current_version.split('.')
		
		if (vnMajorMinor[0] != unityMajorMinor[0] || vnMajorMinor[1] != unityMajorMinor[1])
			isCurrentMajorVersion = false
		elsif (vnMajorMinor[2] != unityMajorMinor[2])
			isCurrentMinorVersion = false
		end
		labelVersion.label += "#{vn}"
	end
	
	#check each version
	
	if (!isCurrentMajorVersion)
		labelVersion.override_background_color(:normal, Gdk::RGBA::new(  1.0, 0.5, 0.5, 1.0))
	elsif (!isCurrentMinorVersion)
		labelVersion.override_background_color(:normal, Gdk::RGBA::new(  1.0, 1.0, 0.5, 1.0))
	elsif (!isCurrentMinorMinorVersion)
		labelVersion.override_background_color(:normal, Gdk::RGBA::new(  1.0, 1.0, 1.0, 1.0))
	end
	$tableGames.attach_defaults(labelVersion, 2, 3, iRow, iRow + 1)
	labelVersion.show


	labelPlaymakerVersion = Gtk::Label.new("")
	if (!gameProject.playmaker_version.nil? )
		labelPlaymakerVersion.label = gameProject.playmaker_version
		
		if (labelPlaymakerVersion.label != $config.playmaker_current_version) 
			labelPlaymakerVersion.override_background_color(:normal, Gdk::RGBA::new(  1.0, 0.5, 0.5, 1.0))
		end

		
	end
	$tableGames.attach_defaults(labelPlaymakerVersion, 3, 4, iRow, iRow + 1)
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

	labelProjectDirectory = Gtk::Label.new
	labelProjectDirectory.label = "Unity Current Version"
	grid.attach(labelProjectDirectory, 0, iRow, 1, 1)

	$textUnityCurrentVersion = Gtk::Entry.new
	$textUnityCurrentVersion.editable = false
	$textUnityCurrentVersion.text = $config.unity_current_version
	grid.attach($textUnityCurrentVersion, 1, iRow, 1, 1)
	
	iRow += 1

	labelUnityExecutable = Gtk::Label.new
	labelUnityExecutable.label = "Unity Executable"
	grid.attach(labelUnityExecutable, 0, iRow, 1, 1)
	
	$textUnityExecutable = Gtk::Entry.new
	$textUnityExecutable.editable = false
	$textUnityExecutable.text = $config.unity_exe
	grid.attach($textUnityExecutable, 1, iRow, 1, 1)
	
	iRow += 1


	puts "Adding new table row"
	window.set_title("Unity Version Display - 2019 Levi D. Smith")



	buttonBox = Gtk::ButtonBox.new(:horizontal)
	buttonBox.add(makePlatformCompilePanel())

## Scan Projects button
	button = Gtk::Button.new(:label => "Scan Projects")
	button.signal_connect "clicked" do |_widget|
		scanProjects()
	end
	buttonBox.add(button)



##Clear build folder button
	button = Gtk::Button.new(:label => "Clear build folder")
	button.signal_connect "clicked" do |_widget|
		clearBuildFolderClicked()
	end
	buttonBox.add(button)

##Scan Unity version button
	button = Gtk::Button.new(:label => "Scan Unity Version")
	button.signal_connect "clicked" do |_widget|
		scanUnityVersion()
	end
#	buttonBox.add(button)



##Copy scripts to project
	button = Gtk::Button.new(:label => "Copy scripts")
	button.signal_connect "clicked" do |_widget|
		copyScriptsClicked()
	end
	buttonBox.add(button)

	
## Make Upload Script button	
	button = Gtk::Button.new(:label => "Make Upload Script")
	button.signal_connect "clicked" do |_widget|
		makeUploadScriptAllSelected()
	end
	buttonBox.add(button)

## Quit button	
	button = Gtk::Button.new(:label => "Quit")
	button.signal_connect "clicked" do |_widget|
		Gtk.main_quit
	end
	buttonBox.add(button)


	grid.attach(buttonBox, 0, iRow, 2, 1)
	iRow += 1


	textResults.buffer.text = 'Hello'
	scrolledWindow.min_content_width = 1200
	scrolledWindow.min_content_height = 600
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
		
		md = Gtk::MessageDialog.new :parent => $mainWindow,
				:flags => :destroy_with_parent, :type => :info,
				:buttons_type => :close, :message => "Tasks completed"
		md.run
		md.destroy
		
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
		
		selectedArray.each do | game |
		
			puts "Make upload script for " + game.name
			strProjectIdentifier = ""

			md = Gtk::MessageDialog.new :parent => $mainWindow,
				:flags => :destroy_with_parent, :type => :question,
				:buttons_type => :ok, :message => "Enter Itch.io identifier for\n" + game.name
#			action_area = md.get_content_area()
			entry = Gtk::Entry.new
#			md.vbox.add(entry)
			md.child.add(entry)
#			action_area.pack_start(entry)
			md.show_all()
			md.run()

			strProjectIdentifier = entry.text
			
			md.destroy()
			
			if (strProjectIdentifier != "")
				makeUploadScript(game, strProjectIdentifier)

				md = Gtk::MessageDialog.new :parent => $mainWindow,
				:flags => :destroy_with_parent, :type => :info,
				:buttons_type => :close, :message => "Itch.io upload script created and saved to\n" + $config.projects_dir + "/" + game.name + "/" + "butler_push_all.bat"
				md.run
				md.destroy
			

			end

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
		
		clearBuildFolder(selectedArray)
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
		
		copyAutoSaveScript(selectedArray)
	else
		puts "No games selected"
	end


end


def scanUnityVersion() 
			getUnityVersion()
			readConfigFile()
			$textUnityCurrentVersion.text = $config.unity_current_version

end



#GUI Startup
readConfigFile()
makeWindow()
if ($config.scan_projects_on_startup)
	puts "scanning projects"
	scanProjects()
end

Gtk.main