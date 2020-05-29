Pod::Spec.new do |spec|

  spec.name         = "MultistageBar"
  spec.version      = "0.0.1"
  spec.summary      = "multistage scrollbar"

  spec.description  = "This is a scrollbar that can be configured to be horizontal, multi-menu, scrollable, and clickable"

  spec.homepage     = "https://github.com/liu5656/MultistageBar"

  spec.license      = "MIT"

  spec.author             = { "x" => "register820@163.com" }
  
  spec.swift_versions = '5.0'
  
  spec.platform     = :ios, "11.0"

  spec.source       = { :git => "https://github.com/liu5656/MultistageBar.git", :tag => "#{spec.version}" }

  # spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  spec.source_files  = "MultistageBar/Segment/**/*"
  
  spec.exclude_files = "Classes/Exclude"
  
  spec.requires_arc = true

end
