module PuppetX; module Parsers; end; end


# The Crontab module contains classes and methods that define a parser for the
# content contained in crontabs.
module PuppetX::Parsers::Crontab
  require 'puppetx/parsers/crontab/crontab_parser'
  require 'puppetx/parsers/crontab/crontab_transformer'

  @parser = CrontabParser.new
  @transformer = CrontabTransformer.new

  # Produces an array of records from the content of a crontab.
  #
  # @api public
  #
  # @param content [String] the content of a crontab as a string.
  # @return [Array<Hash>] an array of records parsed from the content.
  # @return [Array] an empty array if the content contained no jobs.
  def self.parse_crontab(content)
    @transformer.apply(@parser.parse(content))
  end
end
