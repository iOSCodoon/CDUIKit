Pod::Spec.new do |s|
  s.name = 'CDUIKit'
  s.version = '0.0.12'
  s.license = 'MIT'
  s.summary = 'Basic toolset for CodoonSport.'
  s.homepage = 'https://github.com/iOSCodoon'
  s.authors = { 'iOSCodoon' => 'ios@codoon.com' }
  s.source = { :git => 'https://github.com/iOSCodoon/CDUIKit.git', :tag => s.version.to_s, :submodules => true }
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  
  s.dependency 'CDExtensionKit'
  s.dependency 'CDFoundation'

  s.prefix_header_contents = '#import "CDFoundation.h"', '#import "CDExtensionKit.h"'
  
  s.public_header_files = 'CDUIKit/*.h'
  s.source_files = 'CDUIKit/*.{h,m}'
end
