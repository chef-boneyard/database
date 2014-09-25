#
# Author:: Drew J. Sonne (<drew.sonne@gmail.com>)
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
      class Mongo < Chef::Provider
        include Chef::Mixin::ShellOut

        def load_current_resource
          Gem.clear_paths
          require 'mongo'
          @current_resource = Chef::Resource::Database.new(@new_resource.name)
          @current_resource.database_name(@new_resource.database_name)
          @current_resource
        end

        def action_create
          unless exists?
            begin
              Chef::Log.debug("#{@new_resource}: Creating collection 'db.#{new_resource.database_name}.#{new_resource.collection_name}'")
              db.db(new_resource.database_name).create_collection(new_resource.collection_name)
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        def action_drop
          if exists?
            begin
              Chef::Log.debug("#{@new_resource}: Dropping collection 'db.#{new_resource.database_name}.#{new_resource.collection_name}'")
              drop_bson = "use #{new_resource.database_name};"
              drop_bson += "db.#{new_resource.collection_name}.dropCollection();"
              db.query(drop_bson)
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
              @new_resource.updated_by_last_action(true)
            ensure
              close
            end
          end
        end

        private
        def exists?
          db.database_names.include?(@new_resource.database_name)
        end

        def db
          @db ||= begin
            connection = ::Mongo::MongoClient.new(@new_resource.connection[:host], @new_resource.connection[:port] || 27017, :op_timeout => 5, :slave_ok => true)
            connection.database_names # check connection
            connection
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
