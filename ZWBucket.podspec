#
#  Be sure to run `pod spec lint ZWLoggers.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

spec.name         = 'ZWBucket'
spec.summary      = 'An Objective-C database library built over Google LevelDB.'
spec.version      = '1.0.0'
spec.license      =  { :type => 'MIT', :file => 'LICENSE' }
spec.authors      = { 'gavin' => 'lovegavin@outlook.com' }
spec.homepage     = 'https://github.com/GavinZw/ZWBucket'

spec.ios.deployment_target = '8.0'

spec.source       = { :git => 'https://github.com/GavinZw/ZWBucket.git', :tag => spec.version }

spec.requires_arc          = true
spec.source_files = 'ZWBucket/*.{h,m}'
spec.public_header_files = 'ZWBucket/*.{h}'

spec.dependency  'Objective-LevelDB'

end
