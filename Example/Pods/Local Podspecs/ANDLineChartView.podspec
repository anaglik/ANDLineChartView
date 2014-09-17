#
# Be sure to run `pod lib lint ANDLineChartView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ANDLineChartView"
  s.version          = "0.2"
  s.summary          = "ANDLineChartView is easy to use view-based class for displaying animated line chart."
  s.description      = <<-DESC
                       ANDLineChartView is easy to use view-based class for displaying animated line chart.

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/anaglik/ANDLineChartView"
  s.screenshots     = "https://raw.github.com/anaglik/ANDLineChartView/master/screen1.png",
                      "https://raw.github.com/anaglik/ANDLineChartView/master/screen2.png"
  s.license          = 'MIT'
  s.author           = { "Andrzej Naglik" => "dev.an@icloud.com" }
  s.source           = { :git => "https://github.com/anaglik/ANDLineChartView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/andy_namic'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'ANDLineChartView'
end
