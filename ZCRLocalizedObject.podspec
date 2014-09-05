Pod::Spec.new do |s|
  s.name             = "ZCRLocalizedObject"
  s.version          = "0.2.0"
  s.summary          = "Dynamic localization that just works."
  s.homepage         = "https://github.com/zradke/ZCRLocalizedObject"
  s.license          = 'MIT'
  s.author           = { "Zach Radke" => "zach.radke@gmail.com" }
  s.source           = { :git => "https://github.com/zradke/ZCRLocalizedObject.git", :tag => s.version.to_s }

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
end
