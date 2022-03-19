source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/aliyun/aliyun-specs.git'
source 'http://repo.baichuan-ios.taobao.com/baichuanSDK/AliBCSpecs.git'

inhibit_all_warnings!
use_frameworks! :linkage => :static

target 'TTYY' do

  platform :ios, '10.0'
  
  pod 'ReactiveCocoa', "~> 2.0"
#  pod 'pop', '~> 1.0'
#  pod 'TTTAttributedLabel', "1.12.0"
  pod 'MJRefresh', '~> 3.7.2'
  pod 'Bugly',"2.5.90"
#  pod 'FMDB'
  pod 'SDWebImage', "3.8.2"
  pod 'YYWebImage',"1.0.5"
#  pod 'YYImage/WebP',"1.0.4"
#  pod 'YYModel', "1.0.4"
  pod 'YYCache',"1.0.4"
#  pod 'MJExtension',"3.0.13"
#  pod 'Masonry',"1.0.2"
  pod 'AFNetworking',"2.6.3"
  
#  pod 'ZipArchive' #zip压缩/解压缩
  #友盟统计
  pod 'UMCommon', "7.2.5"
  pod 'UMDevice',"1.1.0"
  pod 'UMAPM',"1.1.1"


  #集成指定版本闪验SDK,并在末位小版本范围更新:
#  pod 'CL_ShanYanSDK', '~> 2.3.0.0'

  pod 'SensorsAnalyticsSDK', "3.0.0" #神策SDK
  pod 'SensorsAnalyticsSDK', :subspecs => ['Exception']
  pod 'SensorsFocus', "~> 0.4.1" # 神策智能运营

#  pod 'GBPing'
  pod 'AesGcm', '~> 1.2.2'
  
  pod 'LookinServer', :configurations => ['Debug']
  #Swift
  pod 'Alamofire', '~> 5.4.3' #网络请求
  pod 'KakaJSON', '~> 1.1.2' #Json转换库MJExtention作者开发
  pod 'SnapKit', '~> 5.0.1' #autolayout
  pod 'Cache', '~> 5.3.0'
#  pod 'SQLite.swift', '~> 0.12.0'
#  pod 'CryptoSwift', '~> 1.4.0'
  
  pod 'MBProgressHUD', "1.2.0"
#  pod 'AlicloudHTTPDNS', '1.19.2.7'
  
  pod 'tingyunApp', "2.14.11"

  pod 'YJEncryptSwift', :git => 'https://gitlab.ushaqi.com/iOS/yjencrypt.git'
#  pod 'YJShuMei', :git => 'https://gitlab.ushaqi.com/iOS/YJShuMei.git', :tag => '3.0'
  pod 'YJShareSDK', :git => 'https://gitlab.ushaqi.com/iOS/yjsharesdk.git', :branch => 'feature/ttyy'

#  pod 'BaseModule/TTYY', :path => './../BaseModule'
  pod 'BaseModule/TTYY', :git => 'https://gitlab.ushaqi.com/iOS/BaseModule.git', :commit => '51a4de0e6aa2169896a5c0c643be118984f715b0'
  pod 'YJSWebModule', :git => 'https://gitlab.ushaqi.com/iOS/YJSWebModule.git', :branch => 'ttyy'

# 淘宝
pod 'AlibcTradeSDK','4.0.1.15'
pod 'AliAuthSDK','1.1.0.42-BC3'
pod 'mtopSDK','3.0.0.3-BC'
pod 'securityGuard','5.4.191'
pod 'AliLinkPartnerSDK','4.0.0.24'
pod 'BCUserTrack','5.2.0.18-appkeys'
pod 'UTDID','1.5.0.91'
pod 'WindVane','8.5.0.46-bc11'
pod 'GTSDK','2.6.0.0'
end

target 'NotificationService' do
    platform :ios, '10.0'
    pod 'GTExtensionSDK','2.5.3'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == "BaseModule" || target.name == "YJSWebModule" then
        target.build_configurations.each do |config|
            config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)']
            config.build_settings['OTHER_SWIFT_FLAGS'] << '-D TARGET_TTYY'
            config.build_settings['OTHER_CFLAGS'] ||= ['$(inherited)']
            config.build_settings['OTHER_CFLAGS'] << '-D TARGET_TTYY'
      end
    end
  end
 end


# remove UIKit(UIWebView) rejected by AppStore
pre_install do |installer|
    puts 'pre_install begin....'
    dir_af = File.join(installer.sandbox.pod_dir('AFNetworking'), 'UIKit+AFNetworking')
    Dir.foreach(dir_af) {|x|
      real_path = File.join(dir_af, x)
      if (!File.directory?(real_path) && File.exists?(real_path))
        if((x.start_with?('UIWebView') || x == 'UIKit+AFNetworking.h'))
          File.delete(real_path)
          puts 'delete:'+ x
        end
      end
    }
    puts 'end pre_install.'
end
