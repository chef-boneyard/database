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

require 'chef/provider'

class Chef
  class Provider
    class Database
      class Mysql < Chef::Provider::LWRPBase
        include Chef::Mixin::ShellOut

        action :create do
          Chef::Log.debug("#{new_resource}: Creating database '#{new_resource.database_name}'")
          sql = "CREATE SCHEMA IF NOT EXISTS `#{new_resource.database_name}`"
          sql += " CHARACTER SET = #{new_resource.encoding}" if new_resource.encoding
          sql += " COLLATE = #{new_resource.collation}" if new_resource.collation          
          Chef::Log.debug("#{@new_resource}: Performing query [#{sql}]")
          # test
          # FIXME
          
          # repair
          begin
            db.query(sql)
          ensure
            close
          end
        end

        action :drop do
          Chef::Log.debug("#{new_resource}: Dropping database #{new_resource.database_name}")
          begin
            db.query("DROP SCHEMA IF EXISTS `#{new_resource.database_name}`")
          ensure
            close
          end
        end

        action :query do
          db.select_db(@new_resource.database_name) if @new_resource.database_name
          Chef::Log.debug("#{@new_resource}: Performing query [#{new_resource.sql_query}]")
          begin
            db.query(@new_resource.sql_query)
            db.next_result while db.next_result
            @new_resource.updated_by_last_action(true)
          ensure
            close
          end
        end

        private

        def db
          require 'mysql2'
          @db ||=
            Mysql2::Client.new(
            host: @new_resource.connection[:host],
            username: @new_resource.connection[:username],
            password: @new_resource.connection[:password],
            port: @new_resource.connection[:port]
            )
        end

        def close
          @db.close
        rescue Mysql2::Error
          @db = nil
        end
      end
    end
  end
end
