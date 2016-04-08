#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Copyright:: Copyright (c) 2011 Chef Software, Inc.
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
      class Sqlite < Chef::Provider
        include Chef::Mixin::ShellOut

        def load_current_resource
          Gem.clear_paths
          begin
            require 'sqlite3'
          rescue LoadError
            Chef::Log.fatal('Could not load the required sqlite3 gem. Make sure to include the database::sqlite recipe on your runlist')
            raise
          end
          @current_resource = Chef::Resource::Database.new(@new_resource.name)
          @current_resource.database_name(@new_resource.database_name)
          @current_resource
        end

        def action_create
          unless exists?
            ::File.open(@new_resource.database_name, 'w') {}
            @new_resource.updated_by_last_action(true)
          end
        end

        def action_query
          if exists?
            begin
              if @new_resource.sql_query.is_a?(Array)
                @new_resource.sql_query.each do |sql|
                  Chef::Log.debug("#{@new_resource}: Performing queries [#{sql}]")
                  db.execute(sql)
                end
              else
                Chef::Log.debug("#{@new_resource}: Performing query [#{new_resource.sql_query}]")
                db.execute(@new_resource.sql_query)
              end
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        def action_drop
          if exists?
            begin
              Chef::Log.debug("#{@new_resource}: Dropping database #{new_resource.database_name}")
              ::File.unlink(@new_resource.database_name)
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        private

        def exists?
          ::File.exist?(@new_resource.database_name)
        end

        def db
          @db ||= begin
            ::SQLite3::Database.new(@new_resource.database_name)
          end
        end

        def close
          @db = nil
        end
      end
    end
  end
end
