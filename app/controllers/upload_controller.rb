class UploadController < ApplicationController
  before_filter :set_access_control_headers
  def set_access_control_headers
    response.headers['Access-Control-Allow-Methods']  = 'OPTIONS, HEAD, POST'
    response.headers['Access-Control-Allow-Origin']   = '*'
    response.headers['Access-Control-Expose-Headers'] = 'X-Log, X-Reqid'
    response.headers['Access-Control-Max-Age']        = '2592000'
  end

  def mkblk_options
    response.headers['Access-Control-Allow-Headers']  = 'authorization, content-type'
    render :text => 200, :status => 200
  end

  def mkfile_options
    response.headers['Access-Control-Allow-Headers']  = 'authorization, content-type'
    render :text => 200, :status => 200
  end

  def upload_options
    response.headers['Access-Control-Allow-Headers']  = 'authorization, content-type'
    render :text => 200, :status => 200
  end

  def upload
    response.headers['Access-Control-Allow-Headers']  = 'X-File-Name, X-File-Type, X-File-Size'

    sfu = SingleChunkFileUpload.new params[:key]
    sfu.copy params[:file]

    result = {
      "bucket"                 => "glusterfs" ,
      "token"                  => params[:key],
      "file_size"              => params[:file].size,
      "image_rgb"              => nil,
      "original"               => params[:name],
      "mime"                   => mime_type_by_name(params[:key]),
      "image_width"            => 0,
      "image_height"           => 0,
      "avinfo_format"          => nil,
      "avinfo_total_bit_rate"  => nil,
      "avinfo_total_duration"  => nil,
      "avinfo_video_codec_name"=> nil,
      "avinfo_video_bit_rate"  => nil,
      "avinfo_video_duration"  => nil,
      "avinfo_height"          => nil,
      "avinfo_width"           => nil,
      "avinfo_audio_codec_name"=> nil,
      "avinfo_audio_bit_rate"  => nil,
      "avinfo_audio_duration"  => nil
    }

    render json: result
  end

  def mkblk
    response.headers['Access-Control-Allow-Headers']  = 'X-File-Name, X-File-Type, X-File-Size'

    ctx = Ctx.new(
      deadline: get_deadline_from_authorization,
      ip:       request.remote_ip,
      name:     params[:name],
      chunks:   params[:chunks],
      chunk:    params[:chunk]
    )

    mfuc = MutilChunkFileUpload::Chunk.new ctx
    success = mfuc.copy request.body

    return render text: 500, status: 500 if !success

    result = {
      "ctx"      => ctx.to_s,
      "offset"   => params[:block_size]
    }
    render json: result
  end

  def mkfile
    response.headers['Access-Control-Allow-Headers']  = 'X-File-Name, X-File-Type, X-File-Size'

    key = UrlsafeBase64.decode params[:encoded_key]
    encoded_original = x_vars_hash_from_param["x:original"]
    original = UrlsafeBase64.decode(encoded_original).force_encoding('UTF-8')

    ctx_list = request.body.read.split(",").map {|str| Ctx.parse(str)}

    mc = MutilChunkFileUpload::MergeChunk.new ctx_list
    mc.merge(key)

    result = {
      "bucket"                 => "glusterfs" ,
      "token"                  => key,
      "file_size"              => params[:file_size],
      "image_rgb"              => nil,
      "original"               => original,
      "mime"                   => mime_type_by_name(key),
      "image_width"            => 0,
      "image_height"           => 0,
      "avinfo_format"          => nil,
      "avinfo_total_bit_rate"  => nil,
      "avinfo_total_duration"  => nil,
      "avinfo_video_codec_name"=> nil,
      "avinfo_video_bit_rate"  => nil,
      "avinfo_video_duration"  => nil,
      "avinfo_height"          => nil,
      "avinfo_width"           => nil,
      "avinfo_audio_codec_name"=> nil,
      "avinfo_audio_bit_rate"  => nil,
      "avinfo_audio_duration"  => nil
    }

    render json: result
  end

  private

  def get_deadline_from_authorization
    encoded_put_policy = request.headers["authorization"].split(" ").last.split(":").last
    put_policy_json = UrlsafeBase64.decode encoded_put_policy
    put_policy      = JSON.parse put_policy_json
    put_policy["deadline"]
  end

  def x_vars_hash_from_param
    arr = params[:x_vars].split("/")
    key_count = arr.count%2 == 0 ? arr.count/2 : arr.count/2 + 1
    x_vars_hash = {}
    0.upto(key_count-1) do |i|
      x_vars_hash[arr[i*2]] = arr[i*2+1]
    end
    x_vars_hash
  end

  def mime_type_by_name(file_name)
    mime_type = MIME::Types.type_for(file_name).first
    mime_type.blank? ? "application/octet-stream" : mime_type.to_s
  end

end
