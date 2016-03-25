name 'database'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache 2.0'
description 'provides LWRPs for common database tasks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '5.0.0'

%w(amazon arch centos fedora freebsd oracle redhat scientific suse ubuntu).each do |os|
  supports os
end

depends 'postgresql', '>= 1.0.0'

source_url 'https://github.com/chef-cookbooks/database' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/database/issues' if respond_to?(:issues_url)
