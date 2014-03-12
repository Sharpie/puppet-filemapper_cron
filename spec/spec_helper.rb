require 'simplecov'
SimpleCov.start do
  add_filter '/vendor/'
  add_filter '/spec/'
end

require 'puppetlabs_spec_helper/module_spec_helper'
