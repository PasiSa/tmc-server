require 'lib/system_commands.rb'
require 'lib/tmc_javalib.rb'
require 'fileutils'

javalib_copies = ['spec/fixtures/SimpleExercise/lib/tmc-javalib.jar']

file TmcJavalib.jar_path => FileList["#{TmcJavalib.project_path}/**/*.java"] do
  puts "Compiling #{TmcJavalib.jar_path} ..."
  begin
    TmcJavalib.compile!
  rescue
    puts "*** Failed to compile tmc-javalib ***"
    puts "  Have you done `git submodule update`?"
    puts "  You also need to do this the first time: `git submodule sync; git submodule update --init`"
    puts
    raise
  end
  # In case it was already compiled and ant had nothing to do,
  # we'll touch the jar file to make it newer than the deps.
  FileUtils.touch(TmcJavalib.jar_path) if File.exists?(TmcJavalib.jar_path)
end

namespace :javalib do
  desc "Compiles #{TmcJavalib.jar_path}"
  task :compile => [TmcJavalib.jar_path] + javalib_copies
  
  desc "Cleans #{TmcJavalib.project_path}"
  task :clean do
    TmcJavalib.clean_compiled_files!
  end
  
  desc "Forces a recompile of #{TmcJavalib.jar_path}"
  task :recompile => [:clean, :compile]
end

desc "Compiles #{TmcJavalib.jar_path}"
task :javalib => 'javalib:compile'


javalib_copies.each do |javalib_copy|
  file javalib_copy => TmcJavalib.jar_path do
    FileUtils.cp TmcJavalib.jar_path, javalib_copy
  end
end

# Have rake spec ensure javalib is compiled
task :spec => [TmcJavalib.jar_path] + javalib_copies


