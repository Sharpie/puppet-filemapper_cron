require 'spec_helper'
require 'parslet/rig/rspec'
require 'puppetx/parsers/crontab/crontab_parser'

describe PuppetX::Parsers::Crontab::CrontabParser do

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


  describe 'when parsing comments' do
    it 'should consume lines starting with #' do
      expect(subject.comment_line).to parse("# foo\n")
    end

    it 'should consume lines starting with whitespace and #' do
      expect(subject.comment_line).to parse("  # foo\n")
    end
  end


  describe 'when parsing Puppet Name: comments' do
    it 'should extract the name' do
      expect(subject.puppet_name_line).to parse("# Puppet Name: foo\n").as({
        :puppet_id => 'foo'
      })
    end
  end

  describe 'when parsing environment variables' do
    it 'matches lines of the form NAME=VALUE' do
      expect(subject.env_line).to parse("FOO=BAR\n").as({
        :env_val => 'FOO=BAR'
      })
    end

    it 'allows leading whitespace' do
      expect(subject.env_line).to parse(" \tBAZ=BUZZ_BAR\n").as({
        :env_val => " \tBAZ=BUZZ_BAR"
      })
    end

    it 'does not accept whitespace before =' do
      # I'm pretty sure this is wrong, but it strictly matches the behavior of
      # the core Cron provider. So, we'll test it for now.
      expect(subject.env_line).to_not parse(" \tFOO=BAR")
    end
  end

  describe 'when parsing commands' do
    it 'parses commands starting with schedules' do
      expect(subject.command_line).to parse("* * * * * /bin/true\n").as({
        :schedule => {
          :minute   => '*',
          :hour     => '*',
          :monthday => '*',
          :month    => '*',
          :weekday  => '*'
        },
        :command => '/bin/true'
      })
    end

    it 'parses commands starting with specials' do
      expect(subject.command_line).to parse("@special /bin/true\n").as({
        :schedule => {
          :special   => '@special',
        },
        :command => '/bin/true'
      })
    end

    it 'allows leading whitespace before the schedule' do
      expect(subject.command_line).to parse(" \t* * * * * /bin/true\n")
      expect(subject.command_line).to parse(" \t@special /bin/true\n")
    end

    it 'requires whitespace separating the command and schedule' do
      expect(subject.command_line).to_not parse("* * * * */bin/true\n")
      expect(subject.command_line).to_not parse("@special/bin/true\n")
    end
  end

end
