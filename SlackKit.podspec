Pod::Spec.new do |s|
  s.name             = "SlackKit"
  s.version          = "1.1.1"
  s.summary          = "a Slack client library for OS X, iOS, and tvOS written in Swift"
  s.homepage         = "https://github.com/pvzig/SlackKit"
  s.license          = 'MIT'
  s.author           = { "Peter Zignego" => "peter@launchsoft.co" }
  s.source           = { :git => "https://github.com/pvzig/SlackKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/pvzig'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.requires_arc = true
  s.source_files = 'SlackKit/Sources/*.swift'  
  s.frameworks = 'Foundation'
  s.dependency 'Starscream', '~> 1.1.3'
  s.dependency 'RxCocoa', '~> 2.5.0'
  s.dependency 'RxSwift', '~> 2.5.0'
end

