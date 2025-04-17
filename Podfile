# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Firebase Chat iOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Firebase Chat iOS
#pod 'Firebase/Auth'
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'CodableFirebase'
#pod 'Firebase/Storage'
pod 'FirebaseStorage'
pod 'CountryPickerView'
pod 'SVPinView'
pod 'PhoneNumberKit'
pod 'FirebaseAnalytics'
pod 'IQKeyboardManagerSwift'
pod 'MBProgressHUD'
pod 'Toast-Swift'
pod "TLPhotoPicker"
pod 'ICGVideoTrimmer'
pod 'CropViewController'
pod 'SKPhotoBrowser'
pod 'Nuke'
pod 'JitsiMeetSDK'

  target 'Firebase Chat iOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Firebase Chat iOSUITests' do
    # Pods for testing
  end

end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
            end
        end
    end
end
