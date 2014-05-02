require 'spec_helper'
require 'puppetx/parsers/crontab'

# FIXME: This is more of an integration test, but the rake tasks in
# puppetlabs-spec-helper don't scan the integration subdirectory.
describe PuppetX::Parsers::Crontab do

  describe 'when parsing' do

    context 'an empty crontab' do
      let(:crontab) { '' }

      it 'returns an empty array' do
        parse_result = subject.parse_crontab(crontab)

        expect(parse_result).to be_a(Array)
        expect(parse_result).to be_empty
      end
    end

    context 'a single unnamed job' do
      let(:crontab) { File.read(my_fixture('simple_crontab')) }

      it 'returns an array' do
        expect(subject.parse_crontab(crontab)).to be_a(Array)
      end

      describe 'the returned record' do
        let(:record) { subject.parse_crontab(crontab).first }

        it 'has extracted the command' do
          expect(record).to include({
            :command => '/bin/true'
          })
        end

        it "represents '*' schedule entries as :absent" do
          expect(record).to include({
            :hour     => :absent,
            :minute   => :absent,
            :monthday => :absent,
            :month    => :absent,
            :weekday  => :absent,
          })
        end

        it 'has an :absent special schedule' do
          expect(record).to include({
            :special => :absent
          })
        end

        it 'has an :absent environment' do
          expect(record).to include({
            :environment => :absent
          })
        end

        it 'has a job name set to the line number' do
          expect(record).to include({
            :name => {:line => 1}
          })
        end
      end
    end

    context 'jobs with malformed puppet names' do
      context 'repeated puppet names' do
        let(:crontab) { File.read(my_fixture('repeated_puppet_name')) }
        let(:record) { subject.parse_crontab(crontab).first }

        it 'uses the first Puppet Name' do
          expect(record).to include({
            :name => 'first'
          })
        end
      end

      context 'misplaced puppet names' do
        let(:crontab) { File.read(my_fixture('misplaced_puppet_name')) }
        let(:record) { subject.parse_crontab(crontab).first }

        it 'ignores misplaced names' do
          expect(record).to include({
            :name => 'first'
          })
        end
      end
    end

  end
end
