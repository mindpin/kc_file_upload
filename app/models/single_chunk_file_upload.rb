class SingleChunkFileUpload
  def initialize(save_key)
    @save_key = save_key
    @file_save_path = File.join ENV["upload_file_base_path"], save_key
  end

  def copy(upload_file)
    FileUtils.mkdir_p(File.dirname(@file_save_path))
    FileUtils.mv upload_file.path, @file_save_path
    FileUtils.chmod 0664, @file_save_path
  end

end
