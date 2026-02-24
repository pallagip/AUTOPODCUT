require 'xcodeproj'

project_path = './AUTOPODCUT.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Main target
app_target = project.targets.find { |t| t.name == 'AUTOPODCUT' }
# Create main folder if it doesn't exist
app_group = project.main_group.find_subpath(File.join('AUTOPODCUT', 'Core'), true)
app_group.set_source_tree('<group>')

# Add audio file loader
source_file = app_group.new_reference('AudioFileLoader.swift')
app_target.add_file_references([source_file])

# Tests target
test_target = project.targets.find { |t| t.name == 'AUTOPODCUTTests' }
# Create tests folder if it doesn't exist
test_group = project.main_group.find_subpath(File.join('AUTOPODCUTTests', 'Core'), true)
test_group.set_source_tree('<group>')

# Add audio file loader tests
test_file = test_group.new_reference('AudioFileLoaderTests.swift')
test_target.add_file_references([test_file])

project.save
