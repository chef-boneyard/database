require 'spec_helper'

package_server_name = 'mariadb-server-10.0'
case backend.check_os[:family]
when 'Fedora', 'CentOS', 'RedHat'
  package_server_name = 'MariaDB-server'
end

describe package(package_server_name) do
  it { should be_installed }
end
