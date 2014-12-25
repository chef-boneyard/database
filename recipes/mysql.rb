# Install the mysql2 gem into Chef's environment
mysql2_chef_gem 'default' do
  client_version node['mysql']['version'] if node['mysql']
  action :install
end
