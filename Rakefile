require 'bundler/setup' # Releasy requires require that your application uses bundler.
require 'releasy'

#<<<
Releasy::Project.new do
  name "lampicli"
  version "3.0.0"
  verbose # Can be removed if you don't want to see all build messages.

  executable "lampicli.rb"
  #files "lib/**/*.rb", "config/**/*.yml", "media/**/*.*"
  #exposed_files "README.html", "LICENSE.txt"
  #add_link "http://my_application.github.com", "My Application website"
  exclude_encoding # Applications that don't use advanced encoding (e.g. Japanese characters) can save build size with this.

  # If building on a Windows machine, :windows_folder and/or :windows_installer are recommended.
  ######## after build move bin lib src and ludpc.exe to root directory ########
  add_build :windows_folder do
    icon "resources/lampicli.ico"
    executable_type :console # Assuming you don't want it to run with a console window.
    add_package :exe # Windows self-extracting archive.
  end

  add_build :windows_installer do
    icon "media/icon.ico"
    start_menu_group "Spooner Games"
    readme "README.html" # User asked if they want to view readme after install.
    license "LICENSE.txt" # User asked to read this and confirm before installing.
    executable_type :windows # Assuming you don't want it to run with a console window.
    add_package :zip
  end

  # If unable to build on a Windows machine, :windows_wrapped is the only choice.
  add_build :windows_wrapped do
    wrapper "wrappers/ruby-1.9.3-p0-i386-mingw32.7z" # Assuming this is where you downloaded this file.
    executable_type :windows # Assuming you don't want it to run with a console window.
    exclude_tcl_tk # Assuming application doesn't use Tcl/Tk, then it can save a lot of size by using this.
    add_package :zip
  end

  add_deploy :local # Only deploy locally.
end
#>>>