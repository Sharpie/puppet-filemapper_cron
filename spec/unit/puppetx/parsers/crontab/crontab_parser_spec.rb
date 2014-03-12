require 'spec_helper'
require 'puppetx/parsers/crontab/crontab_parser'

describe PuppetX::Parsers::Crontab::CrontabParser do
  let(:simple_crontab) { File.read(my_fixture('simple_crontab')) }

  it 'parses a simple crontab' do
    expect{ subject.parse(simple_crontab) }.to_not raise_error
  end
end
