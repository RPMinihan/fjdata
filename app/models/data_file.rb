class DataFile < ActiveRecord::Base
 	require 'builder'
 	require 'archive' 
	require 'filemagic'
    def self.save(upload, boxname)
    name =  upload.original_filename
    #the archive directory
    directory = "public/archive"
    # create the file path if doesn't already exist
		fm = ::FileMagic.new
		if boxname.empty? then boxname = "default" end
    unless File.directory?(File.join(directory, boxname))
    	mkdir_p(File.join(directory, boxname))
    end
       
    path = File.join(directory, boxname,  name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload.read) }
    #Check for compressed file formats
    if name.match(/.zip|.acs/i)
    	@list_archive = true
    	chdir (File.join(directory, boxname))
 			unless File.directory?(name + ".contents")
	 			mkdir(name + ".contents")
 			end
 			
 			dirlist = Array.new
 			arc = ::Archive.new(name)
			chdir name + ".contents"
			arc.extract
			fm = ::FileMagic.new
 			Dir.glob("**/*").each { |arc_content|
 													 dirlist << { :filename => arc_content.to_s, 
 													 							:filesize => File.stat(arc_content).size.to_s,
 													 							:filetype => fm.file(arc_content) }
 													}


 			chdir Rails.root.to_s
 			dirlist
 		
		else
			chdir (File.join(directory, boxname))
			dirlist = Array.new
			Dir.glob("**/*").each { |arc_content|
 													 dirlist << { :filename => arc_content.to_s, 
 													 							:filesize => File.stat(arc_content).size.to_s,
 													 							:filetype => fm.file(arc_content) }
 													}
    
    chdir Rails.root.to_s
    dirlist
    end
    
  end #save

	def self.metainfo(username, filesize, notes, boxname, filename)
		dirlist = Array.new
		if boxname.empty? then boxname = "default" end
		fm = ::FileMagic.new
		@xmloutput = ""
		file_xml = ::Builder::XmlMarkup.new(:target => @xmloutput, :indent => 2)
		file_xml.instruct!
		
		if filename.match(/.zip|.acs/i)
			#chdir ("public/archive/#{boxname}/#{filename}.contents")
			chdir (Rails.root.to_s + "/public/archive/#{boxname}")
			Dir.glob("**").each { |arc_content|
													dirlist << { :filename => arc_content.to_s, 
 													 							:filesize => File.stat(arc_content).size.to_s,
 													 							:filetype => fm.file(arc_content) }
 													 						}

 			file_xml.box { |f|
 				f.date Time.now.to_s
 				f.username username
 				f.boxname boxname
				f.notes notes
 				dirlist.each { |entry|
					if File.directory?(entry[:filename]) 
					f.directory("name" => File.basename(entry[:filename])) {
						Dir.glob(entry[:filename] + "/**/*").each {|subdir|
							f.file("name" => File.basename(subdir), "size" => File.stat(subdir).size.to_s, \
							 "type" => `file -b \"#{subdir}\"`, "path" => boxname + "/" + subdir )
						}
					}
					
 					else
 						f.file( "name" => File.basename(entry[:filename]), "size" => entry[:filesize], "path" => boxname + "/" + entry[:filename], "type" => `file -b \"#{entry[:filename]}\"`)
 					end #if File.directory?

 					}
		}
 			File.open("files.xml", "w") {|f|
			f.puts @xmloutput
		}
				
 				
 			chdir Rails.root.to_s
 		
 		else #if filename.match
		
		chdir ("public/archive/#{boxname}/")
		Dir.glob("**/*").each { |arc_content|
													dirlist << { :filename => arc_content.to_s, 
 													 							:filesize => File.stat(arc_content).size.to_s,
 													 							:filetype => fm.file(arc_content) }
 													 						}

 			file_xml.box { |f|
 				f.date Time.now.to_s
 				f.username username
 				f.boxname boxname
				f.notes notes
 				dirlist.each { |entry|
					if File.directory?(entry[:filename]) 
					f.directory("name" => File.basename(entry[:filename])) {
						Dir.glob(entry[:filename] + "/**/*").each {|subdir|
							f.file("name" => File.basename(subdir), "size" => File.stat(subdir).size.to_s, \
							 "type" => fm.file(subdir), "path" => boxname + "/" + subdir )
						}
					}
 					else
 						f.file( "name" => File.basename(entry[:filename]), "size" => entry[:filesize], "path" => boxname + "/" + entry[:filename], "type" => fm.file(entry[:filename]))
 					end #if File.directory?

 					}
		}

		File.open("files.xml", "w") {|f|
			f.puts @xmloutput
		}
			

		chdir Rails.root.to_s
		
	 end # if filename.match

	end #metainfo





end #DataFile

