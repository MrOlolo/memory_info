#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint memory_info.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'memory_info'
  s.version          = '0.0.1'
  s.summary          = 'Get device memory info(ram&rom)'
  s.description      = <<-DESC
Get device memory info(ram&rom)
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.resource_bundles = {'memory_info_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
