Pod::Spec.new do |s|

  s.platform     = :osx
  s.platform     = :ios
  s.name         = "ClearBlade-iOS-API"
  s.version      = "1.18.1"
  s.summary      = "iOS API libraries for the ClearBlade Platform"
  
  s.ios.deployment_target = '7.0'
  s.ios.frameworks = 'MobileCoreServices', 'SystemConfiguration', 'Security', 'CoreGraphics'

  s.osx.deployment_target = '10.8'
  s.osx.frameworks = 'CoreServices', 'SystemConfiguration', 'Security'

  s.tvos.deployment_target = '9.0'
  s.tvos.frameworks = 'MobileCoreServices', 'SystemConfiguration', 'Security'

  s.homepage     = "https://github.com/ClearBlade/iOS-API"
  s.license      = { :type => 'EPL', :file => 'LICENSE' }
  s.author       = { "ClearBlade, Inc." => "support@clearblade.com" }

  s.source       = { :git => "https://github.com/ClearBlade/iOS-API.git", :tag => '1.18.1' }
  s.header_dir = 'libmosquitto'
  s.source_files  = 'ClearBladeAPI/**/*.{h,m,c}'
  s.exclude_files = 'ClearBladeAPI/libmosquitto/*.c' 
  s.requires_arc = true

  s.subspec 'libmosquitto' do |mosq|
    mosq.source_files = 'ClearBladeAPI/libmosquitto/*.{c,h}'
    mosq.requires_arc = false
    mosq.compiler_flags = '-DWITH_THREADING', '-fno-objc-arc'
  end
end
