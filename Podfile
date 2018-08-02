target 'DRNear' do
    use_frameworks!
    inhibit_all_warnings!
    
    
    #Rx
    pod 'RxSwift'
    pod 'RxDataSources'
    
    #UI
    pod 'SnapKit'
    
    target 'DRNearTests' do
        inherit! :search_paths
        
        pod 'Quick'
        pod 'Nimble'
        pod 'RxBlocking'
        pod 'RxTest'
    end
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
        end
    end
end


