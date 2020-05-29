#
#  Be sure to run `pod spec lint MultistageBar.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "MultistageBar"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of MultistageBar."

  spec.description  = "This is a scrollbar that can be configured to be horizontal, multi-menu, scrollable, and clickable"

  spec.homepage     = "http://EXAMPLE/MultistageBar"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  spec.license      = "MIT"

  spec.author             = { "x" => "register820@163.com" }
  
  spec.platform     = :ios

  spec.source       = { :git => "git@github.com:liu5656/MultistageBar.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"
  
  spec.requires_arc = true

end
