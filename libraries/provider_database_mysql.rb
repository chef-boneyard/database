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
      class Mysql < Chef::Provider
        include Chef::Mixin::ShellOut

        def load_current_resource
          Gem.clear_paths
          require 'mysql2'
          @current_resource = Chef::Resource::Database.new(@new_resource.name)
          @current_resource.database_name(@new_resource.database_name)
          @current_resource
        end

        def action_create
          begin
            Chef::Log.debug("#{@new_resource}: Creating database `#{new_resource.database_name}`")
            sql = "CREATE DATABASE IF NOT EXISTS `#{new_resource.database_name}`"
            sql += " CHARACTER SET = #{new_resource.encoding}" if new_resource.encoding
            sql += " COLLATE = #{new_resource.collation}" if new_resource.collation
            Chef::Log.debug("#{@new_resource}: Performing query [#{sql}]")
            db.query(sql)
            @new_resource.updated_by_last_action(true)
          ensure
            close
          end
        end

        def action_drop
          if exists?
            begin
              Chef::Log.debug("#{@new_resource}: Dropping database #{new_resource.database_name}")
              db.query("DROP DATABASE `#{new_resource.database_name}`")
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        def action_query
          if exists?
            begin
              db.select_db(@new_resource.database_name) if @new_resource.database_name
              Chef::Log.debug("#{@new_resource}: Performing query [#{new_resource.sql_query}]")
              db.query(@new_resource.sql_query)
              db.next_result while db.next_result
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        private

        def db
          @db ||= begin
                    connection = ::Mysql2::Client.new(
              host: @new_resource.connection[:host],
              username: @new_resource.connection[:username],
              password: @new_resource.connection[:password],
              port: @new_resource.connection[:port]
              )
                  end
        end

        def close
          @db.close rescue nil
          @db = nil
        end
      end
    end
  end
end
