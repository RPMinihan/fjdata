class Boxes < ActiveRecord::Base
require 'rexml/document'


	def self.list()
		chdir Rails.root.to_s + "/public/archive"
		dirlist = Array.new
		Dir.glob("*").each {|arc_content|
												dirlist << { :filename => arc_content.to_s, 
 													 							:filetime => File.stat(arc_content).mtime.to_s,
 													 							:filetype => `file -b \"#{arc_content}\"` }
 													}	
		chdir Rails.root.to_s
		dirlist
	end
	
	def self.boxlist(boxname)
		chdir "public/archive/#{boxname}"
		dirlist = Array.new
			Dir.glob("**").each { |arc_content|
 													 dirlist << { :filename => arc_content.to_s, 
 													 							:filesize => File.stat(arc_content).size.to_s,
 													 							:filetype => `file -b \"#{arc_content}\"` }
 													}
    
    chdir Rails.root.to_s
    dirlist
	end

	def self.workspace_entries(boxname)
		xmlstring = File.new(Rails.root.to_s + "/public/archive/#{boxname}/files.xml").read
		xmldoc = ::REXML::Document.new (xmlstring)
		uris = Array.new
		xmldoc.elements.each("box/file") {|file|
			if file.attributes["type"].match(/\(FCS\) data/)
				uris << BASE_ARCHIVE + file.attributes["path"]
			end
		}
		xmldoc.elements.each("box/directory/file") {|file|
			if file.attributes["type"].match(/\(FCS\) data/)
				uris << BASE_ARCHIVE + file.attributes["path"]
			end
		}
		uris
		
	
	
	
	
	
	
	#self.boxlist(boxname)

	end
	



end
