require 'rubygems'  
require 'rake'  
require 'echoe'  
  
Echoe.new('gotta_have', '0.1.0') do |p|  
  p.description     = "Check for specific versions of cmd line utilities as dependencies"
  p.url             = "http://github.com/ndelage/gotta_have"  
  p.author          = "Nate Delage"  
  p.email           = "nate@natedelage.com"  
  p.ignore_pattern  = ["tmp/*", "script/*"]
  p.runtime_dependencies = ['open4']
  p.development_dependencies = ['shoulda']
end  
  
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
