class UploadController < ApplicationController
  FILE_BASE_PATH = Rails.root.join("public/static")
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

    file_save_path = File.join FILE_BASE_PATH, params[:key]
    FileUtils.mkdir_p(File.dirname(file_save_path))
    FileUtils.mv params[:file].path, file_save_path
    mime_type = MIME::Types.type_for(file_save_path).first
    mime = mime_type.blank? ? "application/octet-stream" : mime_type.to_s

    result = {
      "bucket"                 => "glusterfs" ,
      "token"                  => params[:key],
      "file_size"              => params[:file].size,
      "image_rgb"              => nil,
      "original"               => params[:name],
      "mime"                   => mime,
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
    ctx_arr = [
      urlsafe_base64_encode("#{request.remote_ip}:#{get_deadline_from_authorization}"),
      urlsafe_base64_encode(params[:name]),
      params[:chunks],
      params[:chunk]
    ]

    file_save_path = File.join FILE_BASE_PATH, ctx_arr[0], ctx_arr[1], ctx_arr[2], ctx_arr[3]
    merge_file_save_path = File.join FILE_BASE_PATH, ctx_arr[0], ctx_arr[1], ctx_arr[2], "merge"
    FileUtils.mkdir_p(File.dirname(file_save_path))
    IO.copy_stream request.body, file_save_path
    success = `cat #{file_save_path} >> #{merge_file_save_path}; echo $?` == "0\n"

    return render text: 500, status: 500 if !success

    result = {
      "ctx"      => ctx_arr.join(":"),
      "offset"   => params[:block_size]
    }
    render json: result
  end

  def mkfile
    response.headers['Access-Control-Allow-Headers']  = 'X-File-Name, X-File-Type, X-File-Size'

    key = urlsafe_base64_decode params[:encoded_key]
    original = x_vars_hash_from_param["x:original"]

    ctx_arr = request.body.read.split(",").map do |ctx|
      ctx.split(":")
    end.last

    chunks_dir = File.join FILE_BASE_PATH, ctx_arr[0], ctx_arr[1], ctx_arr[2]
    merge_file_save_path = File.join chunks_dir, "merge"

    file_save_path = File.join FILE_BASE_PATH, key
    FileUtils.mkdir_p(File.dirname(file_save_path))
    FileUtils.mv merge_file_save_path, file_save_path

    mime_type = MIME::Types.type_for(file_save_path).first
    mime = mime_type.blank? ? "application/octet-stream" : mime_type.to_s

    result = {
      "bucket"                 => "glusterfs" ,
      "token"                  => key,
      "file_size"              => params[:file_size],
      "image_rgb"              => nil,
      "original"               => original,
      "mime"                   => mime,
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
    put_policy_json = Base64.decode64 encoded_put_policy.gsub('_','/').gsub('-', '+')
    put_policy      = JSON.parse put_policy_json
    put_policy["deadline"]
  end

  def urlsafe_base64_encode content
    Base64.encode64(content).strip.gsub('+', '-').gsub('/','_').gsub(/\r?\n/, '')
  end

  def urlsafe_base64_decode encoded_content
    Base64.decode64 encoded_content.gsub('_','/').gsub('-', '+')
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



end
