#
# Cookbook Name:: test
# Recipe:: postgresql
#
# Author:: Nicolas Blanc <sinfomicien@gmail.com>
#
# Copyright (c) 2014, BlaBlaCar
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'postgresql::server'
include_recipe 'database::postgresql'

postgresql_connection_info = {
  :host     => '127.0.0.1',
  :port     => 5432,
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

postgresql_database 'mariadb_foo' do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user 'mariadb_foo_user' do
  connection postgresql_connection_info
  password 'Foutoir'
  database_name 'mariadb_foo'
  host 'localhost'
  privileges [:select, :update, :insert]
  action :create
end
