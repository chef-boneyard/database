require 'spec_helper'

describe 'postgresql_database_test on ubuntu 16.04' do
  let(:runner) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04') }
  let(:chef_run) { runner.converge('postgresql_database_test::default') }

  before do
    stub_command('test -f /var/run/activemq.pid')
  end

  it 'converges successfully' do
    expect { :chef_run }.to_not raise_error
  end
end

describe 'mysql_database_test on ubuntu 16.04' do
  let(:runner) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04') }
  let(:chef_run) { runner.converge('mysql_database_test::default') }

  before do
    stub_command('test -f /var/run/activemq.pid')
  end

  it 'converges successfully' do
    expect { :chef_run }.to_not raise_error
  end
end

describe 'sqlite_database_test on ubuntu 16.04' do
  let(:runner) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04') }
  let(:chef_run) { runner.converge('sqlite_database_test::default') }

  before do
    stub_command('test -f /var/run/activemq.pid')
  end

  it 'converges successfully' do
    expect { :chef_run }.to_not raise_error
  end
end
