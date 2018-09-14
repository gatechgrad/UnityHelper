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
	$tableGames.attach_defaults(checkboxAll, 0, 1, 0, 1)
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


def makeGameProjectRow(gridGames, iRow, gameProject)

#	textGameProjectName = Gtk::Entry.new
#	textGameProjectName.text = gameProject.name
	
#	textGameProjectVersion = Gtk::Entry.new
#	textGameProjectVersion.text = "?"
	
#	gridGames.attach(textGameProjectName, 0, iRow, 1, 1)
#	gridGames.attach(textGameProjectVersion, 1, iRow, 1, 1)

	


#	gameCheckbox = Gtk::CheckButton.new()
#	$tableGames.attach(gameCheckbox, 0, 1, iRow, iRow + 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
#	gameCheckbox.show

#	labelName = Gtk::Label.new(gameProject.name)
#	$tableGames.attach(labelName, 1, 2, iRow, iRow + 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
#	labelName.show
	
#	labelVersion = Gtk::Label.new("")
#	gameProject.versions.each do | version |
#		labelVersion.label = "#{version.versionNumber} (#{version.fileName})"
#	end
#	$tableGames.attach(labelVersion, 2, 3, iRow, iRow + 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
#	labelVersion.show


	
	gameCheckbox = Gtk::CheckButton.new()
	$checkboxArray << gameCheckbox
	$tableGames.attach_defaults(gameCheckbox, 0, 1, iRow, iRow + 1)
	gameCheckbox.show

	labelName = Gtk::Label.new(gameProject.name)
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
	if (labelVersion.label != UNITY_CURRENT_VERSION) 
		labelVersion.override_background_color(:normal, Gdk::RGBA::new(  1.0, 0.5, 0.5, 1.0))
	end
	$tableGames.attach_defaults(labelVersion, 2, 3, iRow, iRow + 1)
	labelVersion.show


	labelPlaymakerVersion = Gtk::Label.new("")
	if (!gameProject.playmaker_version.nil? )
#		puts "PlayMaker version: #{gameProject.playmaker_version}"
		labelPlaymakerVersion.label = gameProject.playmaker_version
		
		if (labelPlaymakerVersion.label != PLAYMAKER_CURRENT_VERSION) 
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


textResults = Gtk::TextView.new()
scrolledWindow = Gtk::ScrolledWindow.new()

labelProjectDirectory = Gtk::Label.new
labelProjectDirectory.label = "Projects Directory"
grid.attach(labelProjectDirectory, 0, iRow, 1, 1)

textProjectDirectory = Gtk::Entry.new
textProjectDirectory.text = PROJECTS_DIR
grid.attach(textProjectDirectory, 1, iRow, 1, 1)

iRow += 1

labelProjectDirectory = Gtk::Label.new
labelProjectDirectory.label = "Unity Current Version"
grid.attach(labelProjectDirectory, 0, iRow, 1, 1)

textUnityCurrentVersion = Gtk::Entry.new
textUnityCurrentVersion.text = UNITY_CURRENT_VERSION
grid.attach(textUnityCurrentVersion, 1, iRow, 1, 1)




iRow += 1
button = Gtk::Button.new(:label => "Check")


$tableGames.attach(Gtk::CheckButton.new(), 0, 1, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
$tableGames.attach(Gtk::Label.new("b"), 1, 2, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
$tableGames.attach(Gtk::Label.new("c"), 2, 3, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)

$tableGames.attach(Gtk::CheckButton.new(), 0, 1, 1, 2, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
$tableGames.attach(Gtk::Label.new("e"), 1, 2, 1, 2, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
$tableGames.attach(Gtk::Label.new("f"), 2, 3, 1, 2, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)




button.signal_connect "clicked" do |_widget|
	puts "Check"
	tableRemoveAll()
#	textResults.buffer.text = displayProjects(textProjectDirectory.text, textUnityCurrentVersion.text)
	gameProjectsList = displayProjects(textProjectDirectory.text, textUnityCurrentVersion.text)
	
#	$tableGames = Gtk::Table.new(1, 1, false)


	makeGameProjectHeaders()
	
	textResults.buffer.text = "Games\n" 
	iGame = 1
	
	$checkboxArray = Array.new
	$gameArray = Array.new


	
	gameProjectsList.each do | game |
	
#		textResults.buffer.text += "Game: #{game.name}\n" 
		makeGameProjectRow(gridGames, iGame, game)
		iGame += 1
	end
	
	

	
#	scrolledWindow.remove(textResults)
	
#	labelTest = Gtk::Label.new
#	labelTest.label = "Test"

#	scrolledWindow.add(labelTest)
#	scrolledWindow.child_notify

puts "Adding new table row"
#$tableGames.attach(Gtk::CheckButton.new(), 0, 1, 2, 3, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
#$tableGames.attach(Gtk::Label.new("e"), 1, 2, 2, 3, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
#$tableGames.attach(Gtk::Label.new("f"), 2, 3, 2, 3, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)

#grid.attach(Gtk::Label.new("f"), 0, 10, 1, 1)

#scrolledWindow.remove($tableGames)
#$tableGames = Gtk::Table.new(1, 1, false)
#$tableGames.attach(Gtk::CheckButton.new(), 0, 1, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
#$tableGames.attach(Gtk::Label.new("x"), 1, 2, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
#$tableGames.attach(Gtk::Label.new("y"), 2, 3, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
#scrolledWindow.add($tableGames)
#mylabel = Gtk::Label.new("y")

#$tableGames.attach(mylabel, 1, 2, 0, 1, Gtk::AttachOptions::EXPAND, Gtk::AttachOptions::SHRINK, 0, 0)
#mylabel.show

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


button = Gtk::Button.new(:label => "Display selected")
button.signal_connect "clicked" do |_widget|
	i = 0
	strSelected = ""
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
grid.attach(button, 1, iRow, 1, 1)
iRow += 1 



button = Gtk::Button.new(:label => "Compile Selected - WebGL")
button.signal_connect "clicked" do |_widget|
		compileWebGLClicked()

end
grid.attach(button, 1, iRow, 1, 1)
iRow += 1 



textResults.buffer.text = 'Hello'
scrolledWindow.min_content_width = 600
scrolledWindow.min_content_height = 400
scrolledWindow.vscrollbar_policy = Gtk::PolicyType::ALWAYS

#scrolledWindow.add(textResults)
#scrolledWindow.add(gridGames)

scrolledWindow.add($tableGames)
grid.attach(scrolledWindow, 0, iRow, 1, 1)



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

makeWindow()