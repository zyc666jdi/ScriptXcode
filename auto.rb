#!/usr/bin/env ruby

#require 'xcodeproj'
require "../xcodeproj/project.rb"

# get project 
$path = File.join(File.dirname(__FILE__), "DemoWithAddLib.xcodeproj")
$project = Xcodeproj::Project.open($path)

# get target 
$target = $project.targets.first
$group = $project.main_group.find_subpath(File.join('DemoWithAddLib'), true)

# add search path for frameworks , library , header
$target.build_configurations.each do |config|
   new_paths = Array["$(PROJECT_DIR)/Frameworks","$(inherited)"]
   config.build_settings['FRAMEWORK_SEARCH_PATHS'] = new_paths
 end
 $project.save

# add private framework and library
$depend_framework_path = File.join(File.dirname(__FILE__), "Frameworks/DemoAFramework.framework")
$depend_framework = $project.frameworks_group.new_file($depend_framework_path)
$target.frameworks_build_phases.remove_file_reference($depend_framework) # remove if alrady added
$project.frameworks_group.remove_reference($depend_framework) # remove if alrady added
$target.frameworks_build_phases.add_file_reference($depend_framework)

# add system framework and library
$target.add_system_library_tbd("sqlite3.0") # .a
sys_path = "Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/Metal.framework" # framwork
sys_group = $project.frameworks_group()
unless ref = sys_group.find_file_by_path(sys_path)
  ref = sys_group.new_file(sys_path, :developer_dir)
end
$target.frameworks_build_phase.add_file_reference(ref, true)
ref

# make change work
$project.save
puts "succeed!!!"
