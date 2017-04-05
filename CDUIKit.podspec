Pod::Spec.new do |s|
  s.name = 'CDUIKit'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'Basic toolset for CodoonSport.'
  s.homepage = 'https://github.com/iOSCodoon'
  s.authors = { 'iOSCodoon' => 'ios@codoon.com' }
  s.source = { :git => 'https://github.com/iOSCodoon/CDUIKit.git', :tag => s.version.to_s, :submodules => true }
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.public_header_files = 'CDUIKit/*.h'
  s.source_files = 'CDUIKit/*.{h,m}'
  s.dependency 'CDExtensionKit'
end
