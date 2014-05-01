require 'spec_helper'
require 'puppetx/parsers/crontab'

# FIXME: This is more of an integration test, but the rake tasks in
# puppetlabs-spec-helper don't scan the integration subdirectory.
describe PuppetX::Parsers::Crontab do
  let(:simple_crontab) { File.read(my_fixture('simple_crontab')) }

  describe 'when parsing crontabs' do

    context 'and the crontab is empty' do
      let(:empty_crontab) { '' }

      it 'returns an empty array' do
        parse_result = subject.parse_crontab(empty_crontab)

        expect(parse_result).to be_a(Array)
        expect(parse_result).to be_empty
      end
    end

    it 'returns an array' do
      expect(subject.parse_crontab(simple_crontab)).to be_a(Array)
    end

    it "converts '*' to :absent in normal schedules" do
      record = subject.parse_crontab(simple_crontab).first

      expect(record).to include({
        :hour     => :absent,
        :minute   => :absent,
        :monthday => :absent,
        :month    => :absent,
        :weekday  => :absent,
      })
    end

    it 'reports special schedules as :absent when normal schedules are used' do
      record = subject.parse_crontab(simple_crontab).first

      expect(record).to include({
        :special => :absent
      })
    end

  end
end
