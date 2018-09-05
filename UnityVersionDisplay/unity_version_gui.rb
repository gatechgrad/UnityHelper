### 2018 Levi D. Smith
### levidsmith.com

require 'gtk3'
require_relative 'unity_version'

window = Gtk::Window.new("Unity Version")
window.set_size_request(640, 480)
window.set_border_width(10)


iRow = 0

grid = Gtk::Grid.new

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
button.signal_connect "clicked" do |_widget|
	puts "Check"
	textResults.buffer.text = displayProjects(textProjectDirectory.text, textUnityCurrentVersion.text)
end
grid.attach(button, 0, iRow, 1, 1)


button = Gtk::Button.new(:label => "Quit")
button.signal_connect "clicked" do |_widget|
	Gtk.main_quit
end
grid.attach(button, 1, iRow, 1, 1)
iRow += 1 

textResults.buffer.text = ''
scrolledWindow.min_content_width = 600
scrolledWindow.min_content_height = 400
scrolledWindow.vscrollbar_policy = Gtk::PolicyType::ALWAYS
scrolledWindow.add(textResults)
#grid.attach(textResults, 0, 2, 1, 1)
grid.attach(scrolledWindow, 0, iRow, 1, 1)

window.add(grid)
window.signal_connect("delete-event") { |_widget| Gtk.main_quit }
window.show_all

Gtk.main