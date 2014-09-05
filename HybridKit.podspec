Pod::Spec.new do |s|
  s.name         = "HybridKit"
  s.version      = "0.0.2"
  s.summary      = "iOS version of HybridKit, a pseudo Web <-> iOS/Android bridge."
  s.homepage     = "http://www.github.com/clayallsopp/HybridKit-iOS"
  s.author       = { "Mert Dumenci" => "mert@dumenci.me", "Clay Allsopp" => "clay@usepropeller.com"}

  s.source       = { :git => "https://github.com/clayallsopp/HybridKit-iOS.git", :tag => "0.0.2" }
  s.platform     = :ios, '6.0'
  s.source_files = 'Classes', 'HybridKit/HybridKit/*.{h,m}'
  s.requires_arc = true
  s.license = {:type => 'MIT', :file => 'LICENSE'}

  s.dependency 'SVProgressHUD', '~> 1.0'
  s.dependency 'HexColors', '~> 2.0'
  s.dependency 'TransitionKit', '~> 1.1'
  s.dependency 'BlocksKit', '~> 2.2'
end