class MimeTypeUtil
  CONVERT_LIST = {
    "application/mp4" => "video/mp4"
  }

  def self.get_mime_by_file_name(file_name)
    mime_type = MIME::Types.type_for(file_name).first.to_s
    return "application/octet-stream" if mime_type.blank?
    _process_mime_type_by_convert_list(mime_type)
  end

  def self._process_mime_type_by_convert_list(mime_type)
    return mime_type if CONVERT_LIST[mime_type].blank?
    CONVERT_LIST[mime_type]
  end
end
