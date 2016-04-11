module MutilChunkFileUpload
  class Chunk
    def initialize(ctx)
      @ctx = ctx
    end

    def copy(upload_chunk)
      FileUtils.mkdir_p(File.dirname(@ctx.chunk_file_path))
      IO.copy_stream upload_chunk, @ctx.chunk_file_path
      `cat #{@ctx.chunk_file_path} >> #{@ctx.merge_file_path}; echo $?` == "0\n"
    end
  end

  class MergeChunk
    def initialize(ctx_list)
      @ctx_list = ctx_list
    end

    def merge(key)
      file_save_path = File.join ENV["upload_file_base_path"], key
      FileUtils.mkdir_p(File.dirname( file_save_path ))
      FileUtils.mv @ctx_list.last.merge_file_path, file_save_path
    end
  end
end
