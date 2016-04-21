#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Author:: Lamont Granquist (<lamont@chef.io>)
# Author:: Marco Betti (<m.betti@gmail.com>)
# Copyright:: 2011-2015 Chef Software, Inc.
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
require File.join(File.dirname(__FILE__), 'provider_database_postgresql_user')

class Chef
  class Resource
    class PostgresqlDatabaseUser < Chef::Resource::DatabaseUser
      CREATE_DB_DEFAULT = false unless defined?(CREATE_DB_DEFAULT)
      CREATE_ROLE_DEFAULT = false unless defined?(CREATE_ROLE_DEFAULT)
      LOGIN_DEFAULT = true unless defined?(LOGIN_DEFAULT)
      REPLICATION_DEFAULT = false unless defined?(REPLICATION_DEFAULT)
      SUPERUSER_DEFAULT = false unless defined?(SUPERUSER_DEFAULT)

      def initialize(name, run_context = nil)
        super
        @resource_name = :postgresql_database_user
        @provider = Chef::Provider::Database::PostgresqlUser
        @createdb = CREATE_DB_DEFAULT
        @createrole = CREATE_ROLE_DEFAULT
        @login = LOGIN_DEFAULT
        @replication = REPLICATION_DEFAULT
        @superuser = SUPERUSER_DEFAULT
        @schema_name = nil
        @allowed_actions.push(:create, :drop, :grant, :grant_schema)
      end

      def createdb(arg = nil)
        set_or_return(
          :createdb,
          arg,
          equal_to: [true, false]
        )
      end

      def createrole(arg = nil)
        set_or_return(
          :createrole,
          arg,
          equal_to: [true, false]
        )
      end

      def login(arg = nil)
        set_or_return(
          :login,
          arg,
          equal_to: [true, false]
        )
      end

      def replication(arg = nil)
        set_or_return(
          :replication,
          arg,
          equal_to: [true, false]
        )
      end

      def schema_name(arg = nil)
        set_or_return(
          :schema_name,
          arg,
          kind_of: String
        )
      end

      def superuser(arg = nil)
        set_or_return(
          :superuser,
          arg,
          equal_to: [true, false]
        )
      end
    end
  end
end
