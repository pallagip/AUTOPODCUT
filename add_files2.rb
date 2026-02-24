require 'xcodeproj'

project_path = './AUTOPODCUT.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Main target
app_target = project.targets.find { |t| t.name == 'AUTOPODCUT' }
app_group = project.main_group.find_subpath(File.join('AUTOPODCUT', 'Core'))

# Add file
source_file = app_group.new_reference('ChannelBufferExtractor.swift')
app_target.add_file_references([source_file])

# Tests target
test_target = project.targets.find { |t| t.name == 'AUTOPODCUTTests' }
test_group = project.main_group.find_subpath(File.join('AUTOPODCUTTests', 'Core'))

# Add test file
test_file = test_group.new_reference('ChannelBufferExtractorTests.swift')
test_target.add_file_references([test_file])

project.save
