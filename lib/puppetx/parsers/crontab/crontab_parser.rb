require 'parslet'

module PuppetX
module Parsers
module Crontab
  class CrontabParser < Parslet::Parser
    rule(:whitespace)     { match('\s') }
    rule(:newline)        { str("\n") }
    rule(:character)      { match('\S') }
    rule(:comment_char)   { str('#') }
    rule(:puppet_nametag) { str('# Puppet Name: ') }

    rule(:rest_of_line)   { (newline.absent? >> any).repeat }
    rule(:special)        { str('@') >> character.repeat }
    rule(:schedule)       {
      character.repeat.as(:minute)   >> whitespace.repeat >>
      character.repeat.as(:hour)     >> whitespace.repeat >>
      character.repeat.as(:monthday) >> whitespace.repeat >>
      character.repeat.as(:month)    >> whitespace.repeat >>
      character.repeat.as(:weekday)
    }

    rule(:blank_line)         { whitespace.repeat.maybe >> newline }
    # Ensure comment line doesn't match Puppet nametags
    rule(:comment_line)       { whitespace.repeat.maybe >> (puppet_nametag.absent? >> comment_char) >> rest_of_line.maybe >> newline }
    rule(:puppet_name_line)   { puppet_nametag >> rest_of_line.as(:puppet_id) >> newline }
    rule(:env_line)           { (match('\s*\w+=') >> rest_of_line).as(:env_val) >> newline }
    rule(:command_line)       { (special.as(:special) | schedule).as(:schedule) >> whitespace.repeat >> rest_of_line.as(:command) >> newline }

    # This piece is a bit convoluted. But, it creates a nested structure that a Parselet transformer can use
    # to resolve whether or not these pieces exist. I'm not sure it is necessary.
    rule(:name_block)  { (blank_line | comment_line | puppet_name_line).repeat.maybe.as(:name_block) }
    rule(:env_block)   { (blank_line | comment_line | env_line).repeat.maybe.as(:env_block) }

    rule(:cron_record) {
      (
        name_block.as(:name) >>
        env_block.as(:environment) >>
        command_line.as(:job)
      )
    }

    rule(:crontab) { cron_record.repeat.maybe.as(:records) }

    root(:crontab)
  end
end
end
end
