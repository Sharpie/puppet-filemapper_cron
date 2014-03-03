require 'puppetx/filemapper'
require 'puppet/util/parslets/crontab'

Puppet::Type.type(:cron).provide(:parslet) do
  include PuppetX::FileMapper

  desc 'Prototype crontab manager'

  def select_file
    # NOTE: In order to be *completely* compatible with the crontab provider,
    # we should also fall back to the target property ...but I currently
    # believe that property needs to go die in a fire.
    user
  end

  def self.target_files
    # FIXME: This works on CentOS. For a more complete list of crontab
    # locations, see the following PR:
    #
    #   https://github.com/puppetlabs/puppet/pull/2136/files#diff-7d6c86785382e05c0252055af2efa381R97
    Pathname.glob('/var/spool/cron/*').map {|p| p.basename.to_s}
  end

  def self.parse_file(filename, contents)
    records = CrontabTransformer.new.apply(CrontabParser.new.parse(contents))

    records.each do |h|
      h[:user] = filename
      h[:target] = filename # Don't ever touch this. Just use user.
      if h[:name].is_a? Hash
        # This means the parser didn't find a Puppet Name for the cron job and
        # stored the line number in the :line entry of a Hash. Make a name up.
        h[:name] = "Unmanaged Job (#{filename}:line #{h[:name][:line]})"
      end
    end

    records
  end

  def self.format_file(filename, providers)
    "* * * * * /bin/yolo\n"
  end
end
