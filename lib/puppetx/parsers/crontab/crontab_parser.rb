require 'parslet'

module PuppetX
module Parsers
module Crontab
  # A Parselet based parser that consumes the contents of a crontab and
  # produces an AST.
  #
  # @api private
  class CrontabParser < Parslet::Parser
    rule(:whitespace)     { match('[[:blank:]]') }
    rule(:newline)        { str("\n") }
    rule(:character)      { match('\S') }
    rule(:comment_char)   { str('#') }
    rule(:puppet_nametag) { str('# Puppet Name: ') }
    rule(:rest_of_line)   { (newline.absent? >> any).repeat }

    rule(:special) {
      (str('@') >> character.repeat(1)).as(:special)
    }
    rule(:schedule) {
      character.repeat(1).as(:minute)   >> whitespace.repeat(1) >>
      character.repeat(1).as(:hour)     >> whitespace.repeat(1) >>
      character.repeat(1).as(:monthday) >> whitespace.repeat(1) >>
      character.repeat(1).as(:month)    >> whitespace.repeat(1) >>
      character.repeat(1).as(:weekday)
    }

    rule(:blank_line)         { whitespace.repeat >> newline }
    # Ensure comment line doesn't match Puppet nametags
    rule(:comment_line)       { whitespace.repeat >> comment_char >> rest_of_line >> newline }
    rule(:puppet_name_line)   { puppet_nametag >> rest_of_line.as(:puppet_id) >> newline }
    rule(:env_line)           { (match('\s*\w+=') >> rest_of_line).as(:env_val) >> newline }
    rule(:command_line)       { whitespace.repeat >> (special | schedule).as(:schedule) >> whitespace.repeat(1) >> rest_of_line.as(:command) >> newline }

    # This piece is a bit convoluted. But, it creates a nested structure that a Parselet transformer can use
    # to resolve whether or not these pieces exist. I'm not sure it is necessary.
    rule(:name_block)  { (blank_line | puppet_name_line | comment_line).repeat.maybe.as(:name_block) }
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
