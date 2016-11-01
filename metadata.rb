name 'database'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache 2.0'
description 'provides LWRPs for common database tasks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '6.1.1'

%w(amazon centos fedora freebsd oracle redhat scientific opensuse opensuseleap suse ubuntu).each do |os|
  supports os
end

depends 'postgresql', '>= 1.0.0'

source_url 'https://github.com/chef-cookbooks/database'
issues_url 'https://github.com/chef-cookbooks/database/issues'
chef_version '>= 12.1' if respond_to?(:chef_version)
