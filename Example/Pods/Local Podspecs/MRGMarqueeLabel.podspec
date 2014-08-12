Pod::Spec.new do |s|
  s.name             = "MRGMarqueeLabel"
  s.version          = "0.1.0"
  s.summary          = "A label with a marquee effect."
  s.homepage         = "https://github.com/Mirego/MRGMarqueeLabel"
  s.license          = 'BSD 3-Clause'
  s.authors          = { 'Mirego, Inc.' => 'info@mirego.com' }
  s.source           = { :git => "https://github.com/Mirego/MRGMarqueeLabel.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Mirego'

  s.platform         = :ios, '7.0'
  s.requires_arc     = true

  s.source_files     = 'Pod/Classes'
end
