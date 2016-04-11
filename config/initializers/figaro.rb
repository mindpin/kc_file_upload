if !File.exists?(Rails.root.join("config/application.yml"))
  puts ""
  puts ""
  puts "****************** 警告 ********************************"
  puts "* 工程目录下没有找到  config/application.yml  文件        "
  puts "*                                                     "
  puts "* 该文件的作用是配置工程运行时所需的环境变量                 "
  puts "*                                                     "
  puts "* 请参考 config/application.yml.sample 来创建和配置该文件 "
  puts "*                                                     "
  puts "* 如果你已经通过其他方式设置了这些环境变量，请忽略该信息       "
  puts "*******************************************************"
  puts ""
  puts ""
end

required_configs = %w{
  upload_file_base_path
}
blank_configs = required_configs.select { |config| ENV[config].blank? }

if blank_configs.count != 0
  puts ""
  puts "****************** 错误提示 ***********************************"
  puts "* 缺少如下这些环境变量"
  blank_configs.each do |config|
    puts "*   #{config}"
  end
  puts "*   "
  puts "* 请在 config/application.yml 中或其他方式增加这些环境变量 "
  puts "**************************************************************"
  puts ""
  exit 1
end
