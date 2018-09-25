### 2018 Levi D. Smith
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


def makeGameProjectGrid()
#	gridGames = Gtk::Grid.new
	
#	labelTest = Gtk::Label.new
#	labelTest.label = "Test"
#	gridGames.attach(labelTest, 0, 0, 1, 1)
	
	
#	return labelTest

end


def makeGameProjectHeaders()
	headerBkgColor = Gdk::RGBA::new(  0.8, 0.8, 0.8, 1.0)

	checkboxAll = Gtk::CheckButton.new()
	checkboxAll.expand = false
	checkboxAll.width_request = 64
#	$tableGames.attach_defaults(checkboxAll, 0, 1, 0, 1)
	$tableGames.attach(checkboxAll, 0, 1, 0, 1, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 0, 0)
	checkboxAll.show
	checkboxAll.signal_connect "clicked" do |_widget|
		
		toggleAllCheckboxes(_widget.active?)
	
	end
	checkboxAll.override_background_color(:normal, headerBkgColor)



	labelName = Gtk::Label.new("Project Name")
	labelName.override_background_color(:normal, headerBkgColor)
	$tableGames.attach_defaults(labelName, 1, 2, 0, 1)
#	$tableGames.attach(labelName, 1, 2, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::EXPAND, 0, 0)
	labelName.show

	labelUnityVersion = Gtk::Label.new("Unity Version")
	labelUnityVersion.override_background_color(:normal, headerBkgColor)
	$tableGames.attach_defaults(labelUnityVersion, 2, 3, 0, 1)
#	$tableGames.attach(labelUnityVersion, 2, 3, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::EXPAND, 0, 0)
	labelUnityVersion.show

	labelPlayMakerVersion = Gtk::Label.new("PlayMaker Version")
	labelPlayMakerVersion.override_background_color(:normal, headerBkgColor)
	$tableGames.attach_defaults(labelPlayMakerVersion, 3, 4, 0, 1)
#	$tableGames.attach(labelPlayMakerVersion, 3, 4, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::EXPAND, 0, 0)
	labelPlayMakerVersion.show
	
	$tableGames.set_row_spacing(0, 8)


end


def makeGameProjectRow(gridGames, iRow, gameProject)

	
	gameCheckbox = Gtk::CheckButton.new()
	$checkboxArray << gameCheckbox

	#	$tableGames.attach_defaults(gameCheckbox, 0, 1, iRow, iRow + 1)
	$tableGames.attach(gameCheckbox, 0, 1, iRow, iRow + 1, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 0, 0)


#	gameCheckbox.override_background_color(:normal, Gdk::RGBA::new(  0.5, 0.5, 1.0, 1.0))
	gameCheckbox.width_request = 64
	gameCheckbox.expand = false
	gameCheckbox.show

#	labelName = Gtk::Label.new(:label => gameProject.name, :hexpand => true)
	labelName = Gtk::Label.new(gameProject.name)
	labelName.expand = true
	labelName.set_alignment(0, 0.5)
#	labelName.override_background_color(:normal, Gdk::RGBA::new(  0.5, 1.0, 0.5, 1.0))
	
	$gameArray << gameProject
	$tableGames.attach_defaults(labelName, 1, 2, iRow, iRow + 1)
	labelName.show
	
	labelVersion = Gtk::Label.new("")
	gameProject.versions.each do | version |
#		labelVersion.label = "#{version.versionNumber} (#{version.fileName})"
		if (labelVersion.label != "")
			labelVersion.label += ", "
		end
		labelVersion.label += "#{version.versionNumber}"
	end
	if (labelVersion.label != $config.unity_current_version) 
		labelVersion.override_background_color(:normal, Gdk::RGBA::new(  1.0, 0.5, 0.5, 1.0))
#	else
#			labelVersion.override_background_color(:normal, Gdk::RGBA::new(  0.5, 0.5, 0.5, 1.0))
	end
	$tableGames.attach_defaults(labelVersion, 2, 3, iRow, iRow + 1)
	labelVersion.show


	labelPlaymakerVersion = Gtk::Label.new("")
	if (!gameProject.playmaker_version.nil? )
#		puts "PlayMaker version: #{gameProject.playmaker_version}"
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
gridGames = Gtk::Grid.new
gridGames.column_homogeneous = false
#gridGames.set_property "column-homogeneous", false


textResults = Gtk::TextView.new()
scrolledWindow = Gtk::ScrolledWindow.new()

labelProjectDirectory = Gtk::Label.new
labelProjectDirectory.label = "Projects Directory"
grid.attach(labelProjectDirectory, 0, iRow, 1, 1)

textProjectDirectory = Gtk::Entry.new
textProjectDirectory.editable = false
textProjectDirectory.text = $config.projects_dir
grid.attach(textProjectDirectory, 1, iRow, 1, 1)

iRow += 1

labelProjectDirectory = Gtk::Label.new
labelProjectDirectory.label = "Unity Current Version"
grid.attach(labelProjectDirectory, 0, iRow, 1, 1)

$textUnityCurrentVersion = Gtk::Entry.new
$textUnityCurrentVersion.editable = false
$textUnityCurrentVersion.text = $config.unity_current_version
grid.attach($textUnityCurrentVersion, 1, iRow, 1, 1)




iRow += 1
button = Gtk::Button.new(:label => "Scan Projects")


#$tableGames.attach(Gtk::CheckButton.new(), 0, 1, 0, 1, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 0, 0)
#$tableGames.attach(Gtk::Label.new("b"), 1, 2, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::EXPAND, 0, 0)
#$tableGames.attach(Gtk::Label.new("c"), 2, 3, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)

#$tableGames.attach(Gtk::CheckButton.new(), 0, 1, 1, 2, Gtk::AttachOptions::SHRINK, Gtk::AttachOptions::SHRINK, 0, 0)
#$tableGames.attach(Gtk::Label.new("e"), 1, 2, 1, 2, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::EXPAND, 0, 0)
#$tableGames.attach(Gtk::Label.new("f"), 2, 3, 1, 2, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)




button.signal_connect "clicked" do |_widget|
	puts "Check"
	tableRemoveAll()
#	textResults.buffer.text = displayProjects(textProjectDirectory.text, $textUnityCurrentVersion.text)
	gameProjectsList = displayProjects(textProjectDirectory.text, $textUnityCurrentVersion.text)
	
#	$tableGames = Gtk::Table.new(1, 1, false)


	makeGameProjectHeaders()
	
	textResults.buffer.text = "Games\n" 
	iGame = 1
	
	$checkboxArray = Array.new
	$gameArray = Array.new


	if (!gameProjectsList.nil?)
		gameProjectsList.each do | game |
	
#		textResults.buffer.text += "Game: #{game.name}\n" 
			makeGameProjectRow(gridGames, iGame, game)
			iGame += 1
		end
	end
	
	

	

puts "Adding new table row"

makeGameProjectGrid()
window.set_title("Update table")


	
end

grid.attach(button, 0, iRow, 1, 1)


button = Gtk::Button.new(:label => "Quit")
button.signal_connect "clicked" do |_widget|
	Gtk.main_quit
end
grid.attach(button, 1, iRow, 1, 1)
iRow += 1 


#Add button row
#panelButtons = Gtk::Alignment.new(0, 0, 0, 0)
#hbox = Gtk::Box.new(:horizontal, 5)


#halign = Gtk::Alignment.new(1, 0, 0, 0)
#halign.add(hbox)

#grid.attach(halign, 1, iRow, 1, 1)
buttonBox = Gtk::ButtonBox.new(:horizontal)

#labelTemp = Gtk::Label.new
#labelTemp.label = "Temp 1"
#buttonBox.add(labelTemp)

#labelTemp = Gtk::Label.new
#labelTemp.label = "Temp 2"
#buttonBox.add(labelTemp)

#labelTemp = Gtk::Label.new
#labelTemp.label = "Temp 3"
#buttonBox.add(labelTemp)


#grid.attach(buttonBox, 0, iRow, 2, 1)
#iRow += 1





button = Gtk::Button.new(:label => "Display selected")
button.signal_connect "clicked" do |_widget|
	i = 0
	strSelected = ""
	if (!$checkboxArray.nil?)
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				strSelected << "#{$gameArray[i].name}\n"
			end
			i += 1
		end
	
		md = Gtk::MessageDialog.new :parent => window,
			:flags => :destroy_with_parent, :type => :info,
			:buttons_type => :close, :message => "Games Selected\n" + strSelected
		md.run
		md.destroy
	end
	
	
							 
	
end
#grid.attach(button, 1, iRow, 1, 1)
#iRow += 1 
buttonBox.add(button)




button = Gtk::Button.new(:label => "Compile Selected - WebGL")
button.signal_connect "clicked" do |_widget|
		compileWebGLClicked()

end
#grid.attach(button, 1, iRow, 1, 1)
#iRow += 1 
buttonBox.add(button)


button = Gtk::Button.new(:label => "Clear build folder")
button.signal_connect "clicked" do |_widget|
		clearBuildFolderClicked()
end
#grid.attach(button, 1, iRow, 1, 1)
#iRow += 1 
buttonBox.add(button)

button = Gtk::Button.new(:label => "Compile Windows")
button.signal_connect "clicked" do |_widget|
		compileWindowsClicked()
end
#grid.attach(button, 1, iRow, 1, 1)
#iRow += 1 
buttonBox.add(button)


button = Gtk::Button.new(:label => "Compile Mac")
button.signal_connect "clicked" do |_widget|
		compileMacClicked()
end
#grid.attach(button, 1, iRow, 1, 1)
#iRow += 1 
buttonBox.add(button)

button = Gtk::Button.new(:label => "Compile Linux")
button.signal_connect "clicked" do |_widget|
		compileLinuxClicked()
end
#grid.attach(button, 1, iRow, 1, 1)
#iRow += 1 
buttonBox.add(button)

button = Gtk::Button.new(:label => "Update Version")
button.signal_connect "clicked" do |_widget|
		getUnityVersion()
		readConfigFile()
		$textUnityCurrentVersion.text = $config.unity_current_version
end
buttonBox.add(button)




grid.attach(buttonBox, 0, iRow, 2, 1)
iRow += 1


textResults.buffer.text = 'Hello'
scrolledWindow.min_content_width = 800
scrolledWindow.min_content_height = 600
scrolledWindow.vscrollbar_policy = Gtk::PolicyType::ALWAYS

#scrolledWindow.add(textResults)
#scrolledWindow.add(gridGames)

scrolledWindow.add($tableGames)
grid.attach(scrolledWindow, 0, iRow, 2, 1)



window.add(grid)
window.signal_connect("delete-event") { |_widget| Gtk.main_quit }
window.show_all

Gtk.main

end

def compileWebGLClicked() 

	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		compileWebGL(selectedArray)
	else
		puts "No games selected"
	end

end


def compileWindowsClicked() 

	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		compileWindows(selectedArray)
	else
		puts "No games selected"
	end

end


def compileMacClicked() 

	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		compileMac(selectedArray)
	else
		puts "No games selected"
	end

end

def compileLinuxClicked() 

	if (!$checkboxArray.nil? && $checkboxArray.count > 0)
		i = 0
		selectedArray = Array.new
		$checkboxArray.each do | checkbox |
			if (checkbox.active?)
				selectedArray << $gameArray[i]
			end	
			i += 1
		end
		
		compileLinux(selectedArray)
	else
		puts "No games selected"
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
#	if (checkbox.active?)
#		selectedArray << $gameArray[i]
#	end	

	
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

readConfigFile()
makeWindow()