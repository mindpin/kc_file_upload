class Ctx
  def initialize(options)
    @deadline = options[:deadline].to_s
    @ip       = options[:ip].to_s
    @name     = options[:name].to_s
    @chunks   = options[:chunks].to_s
    @chunk    = options[:chunk].to_s

    raise "deadline can't blank" if @deadline.blank?
    raise "ip can't blank"       if @ip.blank?
    raise "name can't blank"     if @name.blank?
    raise "chunks can't blank"   if @chunks.blank?
    raise "chunk can't blank"    if @chunk.blank?

    @encode_ip   = UrlsafeBase64.encode @ip
    @encode_name = UrlsafeBase64.encode @name
  end

  def chunk_file_path
    File.join ENV["upload_file_base_path"], @deadline, @encode_ip, @encode_name, @chunks, @chunk
  end

  def merge_file_path
    File.join ENV["upload_file_base_path"], @deadline, @encode_ip, @encode_name, @chunks, "merge"
  end

  def to_s
    [@deadline, @encode_ip, @encode_name, @chunks, @chunk].join(":")
  end

  def self.parse(ctx_str)
    arr = ctx_str.split(":")

    deadline, encode_ip, encode_name, chunks, chunk = *arr
    ip   = UrlsafeBase64.decode encode_ip
    name = UrlsafeBase64.decode encode_name

    Ctx.new(
      deadline: deadline,
      ip:       ip,
      name:     name,
      chunks:   chunks,
      chunk:    chunk
    )
  end
end
