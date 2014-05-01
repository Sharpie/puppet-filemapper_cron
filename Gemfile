source "https://rubygems.org"

gem 'parslet', :require => false
gem 'puppet', (ENV['PUPPET_VERSION'] || '~> 3.5.0'), :require => false

group :development do
  gem 'rspec',        '~> 2.11.0', :require => false
  gem 'mocha',        '~> 0.10.5', :require => false
  gem 'simplecov',    '~> 0.7.1',  :require => false
  gem 'yard',         '~> 0.8.0',  :require => false

  gem "puppetlabs_spec_helper", "~> 0.4.1", :require => false
  # Pin rspec-puppet at 1.0.x as there are currently breaking changes occuring
  # on the master branch. A 2.0 release should happen next.
  gem 'rspec-puppet', '~> 1.0.0', :require => false
end

if File.exists? "#{__FILE__}.local"
    eval(File.read("#{__FILE__}.local"), binding)
end
