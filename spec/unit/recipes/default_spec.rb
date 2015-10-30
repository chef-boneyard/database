require 'spec_helper'

describe 'mysql_database_test::default recipe on Ubuntu 14.04' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new do |node|
      node.automatic[:lsb][:codename] = 'trusty'
    end.converge('mysql_database_test::default')
  end

  it 'converges successfully' do
    expect { :chef_run }.to_not raise_error
  end
end

describe 'postgresql_database_test::default recipe on Ubuntu 14.04' do
  let(:chef_run) do
    ChefSpec::ServerRunner.new do |node|
      node.automatic[:lsb][:codename] = 'trusty'
    end.converge('postgresql_database_test::default')
  end

  it 'converges successfully' do
    expect { :chef_run }.to_not raise_error
  end
end
