# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
platform :ios, '11.0'cl

target 'UW Food App' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for UW Food App

  pod 'SwiftyJSON'
  pod 'Alamofire'
  pod 'SwiftyDrop', '~>4.0'
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'Font-Awesome-Swift'
  pod 'Cosmos', '~> 12.0'
  pod 'ChameleonFramework'

  target 'UW Food AppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'UW Food AppUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
          end
      end
  end

end
