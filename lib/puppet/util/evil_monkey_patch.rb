require 'puppet/provider/cron/crontab'

Puppet.debug 'Evil things are about to happen to the crontab provider.'
Puppet.debug 'Eeeeeeeeeevvvvvviiillllll.'

class Puppet::Type::Cron
  # ParsedFile-based providers (such as crontab) have an accessor that exposes
  # the Provider property_hash as an attribute. This can't be relied upon to be
  # present for every provider.
  #
  # TODO: Submit this upstream as an actual fix.
  def purging
    self[:target] = provider.target
    self[:user] = provider.target
    super
  end
end

class Puppet::Type::Cron::ProviderCrontab
  # Prevent the core crontab provider from participating in prefetching or
  # purging by patching it to return an empty array of instances.
  def self.instances
    []
  end
end
