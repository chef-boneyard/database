#
# Author:: Maksim Horbul (<max@gorbul.net>)
# Cookbook Name:: database
# Library:: mysql_password
#
# Copyright:: 2016 Eligible, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require File.join(File.dirname(__FILE__), 'resource_mysql_database_user')

class MysqlPassword
  # Initializes an object of the MysqlPassword type
  # @param [String] hashed_password mysql native hashed password
  # @return [MysqlPassword]
  def initialize(hashed_password)
    @hashed_password = hashed_password
  end

  # String representation of the object
  # @return [String] hashed password string
  def to_s
    @hashed_password
  end

  module Helpers
    # helper method wrappers the string into a MysqlPassword object
    # @param [String] hashed_password mysql native hashed password
    # @return [MysqlPassword] object
    def mysql_hashed_password(hashed_password)
      MysqlPassword.new hashed_password
    end
  end
end

::Chef::Resource::MysqlDatabaseUser.send(:include, MysqlPassword::Helpers)
