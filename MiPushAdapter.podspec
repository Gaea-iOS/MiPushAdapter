#
# Be sure to run `pod lib lint MiPushAdapter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MiPushAdapter'
  s.version          = '0.4.0'
  s.summary          = 'A short description of MiPushAdapter.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wangxiaotao/MiPushAdapter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wangxiaotao' => '445242970@qq.com' }
  s.source           = { :git => 'https://github.com/wangxiaotao/MiPushAdapter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  
  s.requires_arc = true
  s.prepare_command = './install'
  
  s.public_header_files = 'MiPushAdapter/Classes/MiPushSDK/*.h'
  s.source_files = 'MiPushAdapter/Classes/**/*'
  s.vendored_libraries  = 'MiPushAdapter/Classes/MiPushSDK/libMiPushSDK.a'
  
  s.frameworks = 'MobileCoreServices', 'SystemConfiguration', 'CFNetwork', 'CoreTelephony', 'UserNotifications'
  s.library = 'z', 'xml2', 'resolv'

end
