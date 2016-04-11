class UrlsafeBase64
  def self.encode content
    Base64.encode64(content).strip.gsub('+', '-').gsub('/','_').gsub(/\r?\n/, '')
  end

  def self.decode encoded_content
    Base64.decode64 encoded_content.gsub('_','/').gsub('-', '+')
  end
end
