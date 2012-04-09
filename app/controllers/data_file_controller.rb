class DataFileController < ApplicationController
  def index
  end

  def edit
  end

	def upload

	#render :text => "File has been uploaded successfully"
#=begin
		@filename = params[:userfile].original_filename
		@username = params[:username].to_s
		@filesize = params[:userfile].size.to_s
		@filepath = params[:userfile].path.to_s
		@notes = params[:notes].to_s
		@contenttype = params[:userfile].content_type.to_s
		@myfile = params[:userfile]
		@boxname = params[:boxname].to_s.gsub(/\s+/,'_')
		if @boxname.empty? then @boxname = "default" end
#=end
		
		@list_archive = DataFile.save(params[:userfile], params[:boxname].to_s.gsub(/\s+/,'_') )
		DataFile.metainfo(@username, @filesize, @notes, @boxname, @filename)
	  redirect_to :controller => 'boxes', :action => 'show_files', :boxname => @boxname
	end

	def upload2
	end
	
	
	def new
	end
	

end
