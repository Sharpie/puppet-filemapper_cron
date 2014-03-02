require 'parslet'

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

  rule(:crontab) { cron_record.repeat.maybe }

  root(:crontab)
end

class CrontabTransformer < Parslet::Transform
  rule(:env_val => simple(:x))   { String(x) }
  rule(:puppet_id => simple(:x)) { String(x) }

  rule(:name_block => simple(:x))   { :absent } # Simple title blocks occur when no Puppet Name is matched
  rule(:name_block => sequence(:x)) { x.first }

  rule(:env_block => simple(:x))   { :absent } # Simple environment blocks occur when no env vars are matched
  rule(:env_block => sequence(:x)) { x }

  # The main event
  rule(:name => subtree(:n), :environment => subtree(:e), :job => subtree(:j)) do
    record = {}

    if n == :absent
      record[:name] = "Unmanaged Job (line #{j[:command].line_and_column.first})"
    else
      record[:name] = n
    end

    record[:environment] = e

    default_schedule = {
      :special =>  :absent,
      :minute =>   :absent,
      :hour =>     :absent,
      :monthday => :absent,
      :month =>    :absent,
      :weekday =>  :absent,
    }

    j[:schedule].delete_if {|k, v| v.to_s == '*'} # These just become :absent
    j[:schedule].each do |k, v|
      if k == :special # Because :special is... special.
        j[:schedule][k] = v.to_s
      else
        j[:schedule][k] = v.to_s.split(',')
      end
    end

    record.merge! default_schedule.update(j[:schedule])
    record[:command] = j[:command].to_s

    record
  end
end
