require 'parslet'

module PuppetX
module Parsers
module Crontab
  # A Parselet based transformer that converts the AST produced by the
  # CrontabParser into an array of records.
  #
  # @api private
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
        # Pass absent values through as a hash with the line number that the job
        # was found on.
        record[:name] = {:line => j[:command].line_and_column.first}
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

    rule(:records => simple(:x))  { [] } # Nothing parsed
    rule(:records => subtree(:x)) { x }
  end
end
end
end
