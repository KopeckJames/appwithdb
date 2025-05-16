#!/usr/bin/env ruby

require 'xcodeproj'

# Path to the Xcode project
project_path = 'iOSAuthApp/iOSAuthApp.xcodeproj'

# Open the project
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Get the main group
main_group = project.main_group

# Find or create the Services group
services_group = main_group.find_subpath('iOSAuthApp/Services', true)
services_group ||= main_group.new_group('Services', 'iOSAuthApp/Services')

# Find or create the Models group
models_group = main_group.find_subpath('iOSAuthApp/Models', true)
models_group ||= main_group.new_group('Models', 'iOSAuthApp/Models')

# Find or create the Views group
views_group = main_group.find_subpath('iOSAuthApp/Views', true)
views_group ||= main_group.new_group('Views', 'iOSAuthApp/Views')

# Files to add
files_to_add = [
  { path: 'iOSAuthApp/iOSAuthApp/Services/OpenAIService.swift', group: services_group },
  { path: 'iOSAuthApp/iOSAuthApp/Models/MealExtensions.swift', group: models_group },
  { path: 'iOSAuthApp/iOSAuthApp/Models/CoreDataMigration.swift', group: models_group },
  { path: 'iOSAuthApp/iOSAuthApp/Models/CoreDataModelUpdater.swift', group: models_group },
  { path: 'iOSAuthApp/iOSAuthApp/Views/MainTabView.swift', group: views_group }
]

# Add files to the project
files_to_add.each do |file_info|
  file_path = file_info[:path]
  group = file_info[:group]
  
  # Check if file exists
  if File.exist?(file_path)
    # Check if file is already in the project
    file_ref = group.find_file_by_path(File.basename(file_path))
    
    if file_ref.nil?
      # Add file to the project
      file_ref = group.new_file(file_path)
      
      # Add file to the target
      target.add_file_references([file_ref])
      
      puts "Added #{file_path} to the project"
    else
      puts "File #{file_path} is already in the project"
    end
  else
    puts "Warning: File #{file_path} does not exist"
  end
end

# Save the project
project.save

puts "Project updated successfully"
