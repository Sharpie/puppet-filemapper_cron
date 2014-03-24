require 'spec_helper'
require 'parslet/rig/rspec'
require 'puppetx/parsers/crontab/crontab_parser'

describe PuppetX::Parsers::Crontab::CrontabParser do
  let(:simple_crontab) { File.read(my_fixture('simple_crontab')) }

  describe 'when parsing schedules' do

    context 'and the schedule is special' do
      it 'should consume input beginning with @' do
        expect(subject.special).to parse('@schedule').as({:special => '@schedule'})
      end

      it 'should require input to follow @' do
        expect(subject.special).to_not parse('@')
      end
    end

    context 'and the schedule is normal' do
      it 'should consume five space delimited groups' do
        expect(subject.schedule).to parse('0,15,30,45 8-18,20-22 31 12 7').as({
          :minute   => '0,15,30,45',
          :hour     => '8-18,20-22',
          :monthday => '31',
          :month    => '12',
          :weekday  => '7'
        })
      end

      it 'should require space between groups' do
        expect(subject.schedule).to_not parse('*****')
      end

      it 'should consume extra whitespace between groups' do
        expect(subject.schedule).to parse('*  *  *  *  *')
        expect(subject.schedule).to parse("*\t* *\t* *")
      end

      it 'should not consume less than five groups' do
        expect(subject.schedule).to_not parse('* * * *')
      end

      it 'should not consume more than five groups' do
        expect(subject.schedule).to_not parse('* * * * * *')
      end
    end

  end


  describe 'when parsing blank lines' do
    it 'should consume single newlines' do
      expect(subject.blank_line).to parse("\n")
    end

    it 'should consume lines consisting of whitespace and a newline' do
      expect(subject.blank_line).to parse(" \t\n")
    end
  end

end
