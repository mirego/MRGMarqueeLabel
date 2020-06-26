Pod::Spec.new do |s|
  s.name             = "MRGMarqueeLabel"
  s.version          = "1.0.7"
  s.summary          = "A label with a marquee effect."
  s.homepage         = "https://github.com/Mirego/MRGMarqueeLabel"
  s.license          = 'BSD 3-Clause'
  s.authors          = { 'Mirego, Inc.' => 'info@mirego.com' }
  s.source           = { :git => "https://github.com/Mirego/MRGMarqueeLabel.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Mirego'

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.requires_arc     = true
  s.source_files     = 'Pod/Classes'
end
