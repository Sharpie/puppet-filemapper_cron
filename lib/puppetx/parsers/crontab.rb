require 'puppetx/parsers/crontab/crontab_parser'
require 'puppetx/parsers/crontab/crontab_transformer'

# Stack it all up here to avoid a redundant forward declaration.
module PuppetX
module Parsers
module Crontab
  @parser = CrontabParser.new
  @transformer = CrontabTransformer.new

  def self.parse_crontab(content)
    @transformer.apply(@parser.parse(content))
  end
end
end
end
