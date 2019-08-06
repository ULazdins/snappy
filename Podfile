# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def allPods
  use_frameworks!

  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
end

target 'Snapp' do
  allPods
end

target 'Artsy' do
  allPods
end

target 'Bez-e' do
  allPods
end

target 'SnappTests' do
  inherit! :search_paths
  
  pod 'RxBlocking', '~> 5'
  pod 'RxTest', '~> 5'
end

target 'SnappUITests' do
  inherit! :search_paths
  
  pod 'RxBlocking', '~> 5'
  pod 'RxTest', '~> 5'
end
