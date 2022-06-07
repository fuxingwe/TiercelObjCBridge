导入静态库的方式：
1.直接拖入到xcode工程 or 放到unity的Plugins目录下会自动在导出xcode工程时引入进去
2.TiercelObjCBridge和Tiercel打开workspace工程都改为静态库，设置Mach-O Type为Static Library（https://blog.csdn.net/sinat_16714231/article/details/52857222）
TiercelObjCBridge的workspace工程中拖入最新Tiercel工程，并改为Do Not Embed（静态库引入方式），注释掉报错代码（比如statusCode变量缺失，logLevel相关）。添加moveTask方法
把Run都改成Release之后分别Build两个workspace工程，到product输出中找到两个framework
在工程中引入TiercelObjCBridge.framework和Tiercel.framework，引用头文件，即可使用。（Unity工程是放到Plugin目录里）

xcoce工程配置解决混编报错问题：（https://shannonchenchn.github.io/2020/06/08/how-to-mix-objc-and-swift-in-a-modular-project/）  https://qastack.cn/programming/52536380/why-linker-link-static-libraries-with-errors-ios
Unity自动化的话需要在后处理里执行：
//支持swift库混编，不良人3是添加到UnityFramework这个Target上
pbxProject.AddBuildProperty(frameworkTarget, "LIBRARY_SEARCH_PATHS","$(SDKROOT)/usr/lib/swift");
pbxProject.AddBuildProperty(frameworkTarget, "LIBRARY_SEARCH_PATHS","$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)");
pbxProject.AddBuildProperty(frameworkTarget, "LIBRARY_SEARCH_PATHS","$(TOOLCHAIN_DIR)/usr/lib/swift-5.0/$(PLATFORM_NAME)");
pbxProject.SetBuildProperty(frameworkTarget, "LD_RUNPATH_SEARCH_PATHS","/usr/lib/swift $(inherited) @executable_path/Frameworks @loader_path/Frameworks");
//  pbxProject.SetBuildProperty(pbxProject.GetUnityFrameworkTargetGuid(), "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES", "YES");
pbxProject.SetBuildProperty(frameworkTarget, "BUILD_LIBRARY_FOR_DISTRIBUTION", "YES");

   
Podfile的方式：
1.引入swift的库使用use_frameworks!方式更好，没有报错
2.不使用use_frameworks!方式，需要解决头文件找不到的问题
source 'https://gitee.com/wyky_ios/Spec.git'
source 'https://cdn.cocoapods.org'

platform :ios, '10.0'

target 'Unity-iPhone' do
    #指定SuperSDK资源
    pod 'YCSuperSDK', :git => 'https://gitee.com/wyky_ios/SuperSDK.git', :branch => 'dmc-c'
    pod 'SuperSDKPluginTools', :git => 'https://gitee.com/wyky_ios/SuperSDKPluginTools.git', :branch => 'dmc-c'
    #指定OpenSDK资源、子模块(根据需要指定子模块)
    pod 'YCOpenSDK', :git => 'https://gitee.com/wyky_ios/OpenSDK.git', :branch => 'dmc-c', :subspecs => ['Framework'] 
    #指定YCSuperSDK_Plugin资源、子模块(根据需要指定子模块)
    pod 'YCSuperSDK_Plugin', :git => 'https://gitee.com/wyky_ios/SuperSDK_Plugin.git', :branch => 'dmc-c', :subspecs => ['Browser', 'GameController', 'ToolBox','NativeSystemCallback','NotchScreen']
    #指定接入代码资源
    pod 'SDK_OpenSDK'
	
	pod 'TiercelObjCBridge', :git => 'https://gitee.com/wyky_ios/TiercelObjCBridge.git'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
        compatibilityPhase = target.build_phases.find { |ph| ph.display_name == 'Copy generated compatibility header' }
        if compatibilityPhase
            build_phase = target.new_shell_script_build_phase('Copy Swift Generated Header')
            build_phase.shell_script = <<-SH.strip_heredoc
                COMPATIBILITY_HEADER_PATH="${BUILT_PRODUCTS_DIR}/Swift Compatibility Header/${PRODUCT_MODULE_NAME}-Swift.h"
                ditto "${COMPATIBILITY_HEADER_PATH}" "${PODS_ROOT}/Headers/Public/${PRODUCT_MODULE_NAME}/${PRODUCT_MODULE_NAME}-Swift.h"
            SH
        end
  end
end