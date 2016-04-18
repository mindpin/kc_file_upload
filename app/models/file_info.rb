class FileInfo
  def initialize(key)
    @key = key
    @mime = MimeTypeUtil.get_mime_by_file_name(@key)
    @file_path = File.join ENV["upload_file_base_path"], key
  end

  def info
    @info ||= _get_info
  end

  def _get_info
    return _video_info if is_video?
    return _image_info if is_image?
    return _audio_info if is_audio?
    _base_info
  end

  def is_video?
    @mime.split("/").first == "video"
  end

  def is_image?
    @mime.split("/").first == "image"
  end

  def is_audio?
    @mime.split("/").first == "audio"
  end

  def _video_info
    movie = FFMPEG::Movie.new(@file_path)
    {
      "avinfo_format"          => movie.container,
      "avinfo_total_bit_rate"  => movie.bitrate,
      "avinfo_total_duration"  => movie.duration,
      "avinfo_video_codec_name"=> movie.video_codec,
      "avinfo_video_bit_rate"  => movie.video_bitrate,
      "avinfo_video_duration"  => movie.duration,
      "avinfo_height"          => movie.height,
      "avinfo_width"           => movie.width,
      "avinfo_audio_codec_name"=> movie.audio_codec,
      "avinfo_audio_bit_rate"  => movie.audio_bitrate,
      "avinfo_audio_duration"  => movie.duration
    }
  end

  def _audio_info
    movie = FFMPEG::Movie.new(@file_path)
    {
      "avinfo_total_bit_rate"  => movie.bitrate,
      "avinfo_total_duration"  => movie.duration,
      "avinfo_audio_codec_name"=> movie.audio_codec,
      "avinfo_audio_bit_rate"  => movie.audio_bitrate,
      "avinfo_audio_duration"  => movie.duration
    }
  end

  def _image_info
    image = ImageHistogram.new(@file_path)
    movie = FFMPEG::Movie.new(@file_path)
    {
      "image_rgb"    => image.qiniu_image_ave,
      "image_height" => movie.height,
      "image_width"  => movie.width

    }
  end

  def _base_info
    {}
  end

end
