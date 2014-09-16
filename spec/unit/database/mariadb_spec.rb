require 'spec_helper'

describe 'debian => database::mariadb' do
  let(:chef_run) do
    ChefSpec::Runner.new(platform: 'debian', version: '7.4',
      step_into: ['mysql2_chef_gem_installer']) do |node|
    end.converge('database::mariadb')
  end

  it 'install the needed dev files' do
    expect(chef_run).to include_recipe('mariadb::client')
  end

  it 'include recipe mysql2_chef_gem' do
    expect(chef_run).to include_recipe('mysql2_chef_gem::mariadb')
  end

  it 'install chef_gem mysql2' do
    expect(chef_run).to install_chef_gem('mysql2')
  end
end
