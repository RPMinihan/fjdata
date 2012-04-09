# Load the rails application
require File.expand_path('../application', __FILE__)
require "fileutils"
include FileUtils

# Initialize the rails application
Fjdata::Application.initialize!
