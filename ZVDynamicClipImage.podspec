#
#  Be sure to run `pod spec lint ZVDynamicClipImage.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "ZVDynamicClipImage"
  spec.version      = "0.0.1"
  spec.summary      = "动态区域裁剪图片的iOS库"
  spec.homepage     = "https://github.com/xnxy/ZVDynamicClipImage.git"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "拿根针尖对麦芒" => "1661583063@qq.com" }
  spec.social_media_url   = "https://xnxy.github.io"
  spec.platform     = :ios, "8.0"
  spec.source       = { :git => "https://github.com/xnxy/ZVDynamicClipImage.git", :tag => "#{spec.version}" }
  spec.source_files  = "ZVDynamicClipImage/ZVDynamicClipImage/ZVDynamicClipImage.h"

  spec.subspec 'Private' do |specB|
    specB.source_files = "ZVDynamicClipImage/ZVDynamicClipImage/Private/*"
  end
  
  spec.subspec 'Public' do |specC|
    specC.source_files = "ZVDynamicClipImage/ZVDynamicClipImage/Public/*"
    specC.dependency 'ZVDynamicClipImage/Private'
  end

end
