Rails.application.routes.draw do
  post "/mkblk/:block_size" => "upload#mkblk"

  post "/mkfile/:file_size/key/:encoded_key/*x_vars" => "upload#mkfile"

  match "/mkblk/:block_size" => "upload#mkblk_options", via: :options

  match "/mkfile/:file_size/key/:encoded_key/*x_vars" => "upload#mkfile_options", via: :options


  post "/" => "upload#upload"
  match "/" => "upload#upload_options", via: :options
end
