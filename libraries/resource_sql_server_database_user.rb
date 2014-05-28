#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
# License:: Apache License, Version 2.0
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
#

require File.join(File.dirname(__FILE__), 'resource_database_user')
require File.join(File.dirname(__FILE__), 'provider_database_sql_server_user')

class Chef
  class Resource
    class SqlServerDatabaseUser < Chef::Resource::DatabaseUser
      def initialize(name, run_context = nil)
        super
        @sql_roles = {}
        @sql_sys_roles = {}
        @resource_name = :sql_server_database_user
        @provider = Chef::Provider::Database::SqlServerUser
        @allowed_actions.push(:alter_roles, :alter_sys_roles)
        @windows_user = false
      end
    end

    def windows_user(arg = nil)
      set_or_return(
          :windows_user,
          arg,
          :kind_of => [TrueClass, FalseClass],
          :default => false
      )
    end

    def sql_roles(arg = nil)
      Chef::Log.debug("Received roles: #{arg.inspect}")
      set_or_return(
          :sql_roles,
          arg,
          :kind_of => Hash
      )
    end

    def sql_sys_roles(arg = nil)
      Chef::Log.debug("Received Server roles: #{arg.inspect}")
      set_or_return(
          :sql_sys_roles,
          arg,
          :kind_of => Hash
      )
    end
  end
end
