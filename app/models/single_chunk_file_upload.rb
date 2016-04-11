class SingleChunkFileUpload
  FILE_BASE_PATH = Rails.root.join("public/static")

  def initialize(save_key)
    @save_key = save_key
    @file_save_path = File.join FILE_BASE_PATH, save_key
  end

  def copy(upload_file)
    FileUtils.mkdir_p(File.dirname(@file_save_path))
    FileUtils.mv upload_file.path, @file_save_path
  end

end
