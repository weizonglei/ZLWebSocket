#
# Be sure to run `pod lib lint ZLWebSocket.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZLWebSocket'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ZLWebSocket.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/weizonglei/ZLWebSocket'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'weizonglei' => '825355821@qq.com' }
  s.source           = { :git => 'https://github.com/weizonglei/ZLWebSocket.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZLWebSocket/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZLWebSocket' => ['ZLWebSocket/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SocketRocket'
  s.dependency 'MJExtension', '~> 3.0.9'
  s.dependency 'AFNetworking', '~> 3.0'
  s.dependency 'Protobuf'
  
end
