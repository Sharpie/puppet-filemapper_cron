require 'puppetx/filemapper'
require 'puppet/util/parslets/crontab'

Puppet::Type.type(:cron).provide(:parslet) do
  include PuppetX::FileMapper

  desc 'Prototype crontab manager'

  def select_file
    'root'
  end

  def self.target_files
    Pathname.glob('/var/spool/cron/*').map {|p| p.basename.to_s}
  end

  def self.parse_file(filename, contents)
    CrontabTransformer.new.apply(CrontabParser.new.parse(contents))
  end

  def self.format_file(filename, providers)
    "* * * * * /bin/yolo\n"
  end
end
