#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zuraffa_intents.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zuraffa_intents'
  s.version          = '1.0.0'
  s.summary          = 'The incoming-share seam for the Zuraffa ecosystem (iOS implementation).'
  s.description      = <<-DESC
The iOS native implementation of the zuraffa_intents plugin: receives incoming
shared text/media over the shared-media event channel and answers the
ZuraffaIntentsApi pigeon channels.
                       DESC
  s.homepage         = 'https://github.com/arrrrny/zuraffa_intents'
  s.license          = { :type => 'BSD-3-Clause', :file => '../LICENSE' }
  s.author           = { 'arrrrny' => 'https://github.com/arrrrny' }
  s.source           = { :path => '.' }
  s.source_files     = 'Sources/zuraffa_intents/**/*', 'Sources/zuraffa_intents_models/**/*'
  s.public_header_files = []
  s.dependency 'Flutter'
  s.platform         = :ios, '15.6'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version    = '5.9'
end
