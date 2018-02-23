Pod::Spec.new do |s|
  s.name             = 'MK_Camera'
  s.version          = '0.1.0'
  s.summary          = '快捷的iOS相机'
 
  s.description      = <<-DESC
    将iOS相机的功能集合到一个View上,后续会继续丰富其中的功能~ 详情看主页~(๑•ᴗ•๑)
                       DESC
 

  s.homepage         = 'hhttps://github.com/dearmiku/MK_Camera.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dear_Miku' => '372154465@qq.com' }
  s.source           = { :git => 'https://github.com/dearmiku/MK_Camera.git', :tag => s.version.to_s }
 

  s.ios.deployment_target = "8.0"

  s.source_files = 'MK_Camera/MK_Camera/Classes/*.swift'

  s.swift_version    = '4.0' 

 
end