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
require File.join(File.dirname(__FILE__), 'provider_database_mysql_user')

class Chef
  class Resource
    class MysqlDatabaseUser < Chef::Resource::DatabaseUser

      def initialize(name, run_context=nil)
        super
        @resource_name = :mysql_database_user
        @provider = Chef::Provider::Database::MysqlUser

        @require_ssl = false
        @require_x509 = false
        @grant_option = false
      end

      def require_ssl(arg=nil)
        set_or_return(:require_ssl, arg, :kind_of => [TrueClass, FalseClass])
      end

      def require_x509(arg=nil)
        set_or_return(:require_x509, arg, :kind_of => [TrueClass, FalseClass])
      end

      def ssl_cipher(arg=nil)
        set_or_return(:ssl_cipher, arg, :kind_of => String)
      end

      def ssl_issuer(arg=nil)
        set_or_return(:ssl_issuer, arg, :kind_of => String)
      end

      def ssl_subject(arg=nil)
        set_or_return(:ssl_subject, arg, :kind_of => String)
      end

      def grant_option(arg=nil)
        set_or_return(:grant_option, arg, :kind_of => [TrueClass, FalseClass])
      end

      def max_queries_per_hour(arg=nil)
        set_or_return(:max_queries_per_hour, arg, :kind_of => Integer)
      end

      def max_updates_per_hour(arg=nil)
        set_or_return(:max_updates_per_hour, arg, :kind_of => Integer)
      end

      def max_connections_per_hour(arg=nil)
        set_or_return(:max_connections_per_hour, arg, :kind_of => Integer)
      end

      def max_user_connections(arg=nil)
        set_or_return(:max_user_connections, arg, :kind_of => Integer)
      end


    end
  end
end