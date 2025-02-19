
Pod::Spec.new do |s|
  s.name             = 'TiercelObjCBridge'
  s.version          = '1.0.4'
  s.swift_version   = '5.0'
  s.summary          = 'TiercelObjCBridge is an extension of Tiercel.'

  s.homepage         = 'https://gitee.com/wyky_ios/TiercelObjCBridge'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fx' => 'fuxing@game2sky.com' }
  s.source           = { :git => 'https://gitee.com/wyky_ios/TiercelObjCBridge.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/**/*.swift'
  s.requires_arc = true
  s.frameworks = 'CFNetwork'
  s.dependency 'Tiercel', '3.2.1'
end
