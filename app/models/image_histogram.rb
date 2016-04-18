class ImageHistogram
  REGEXP = /^.*\:\s*\([\d\s\,]*\)\s*(?<hex>\#\h*)\s*(?<rgba>.*)$/
  def initialize(file_path)
    @file_path = file_path
  end

  def info
    raw = `convert #{@file_path} -format %c -colors 1 -depth 8 -colorspace RGB -alpha On histogram:info:`
    raw = raw.strip.match(REGEXP)
    {
      :rgba => raw[:rgba],
      :hex  => raw[:hex][0, 7],
      :qiniu_image_ave  => "0x#{raw[:hex][1, 7]}"
    }
  rescue
    {
      :rgba => "rgba(204,204,204,0)",
      :hex  => "#cccccc",
      :qiniu_image_ave  => "0xcccccc"
    }
  end

  def qiniu_image_ave
    info[:qiniu_image_ave]
  end

end
