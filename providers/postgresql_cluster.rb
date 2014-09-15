#
# Cookbook Name:: database
# Provider:: cluster
#

# Support whyrun
def whyrun_supported?
  true
end

action :init do
  description = "initialize #{new_resource.name} PostgreSQL cluster"
  converge_by(description) do

    cluster_version = node.postgresql.version
    cluster_name = "main"
    cluster_port = 5432
    config_path = "/etc/postgresql/#{cluster_version}/#{cluster_name}"
    config_file = "#{config_path}/postgresql.conf" 
    hba_file = "#{config_path}/pg_hba.conf" 

    cluster_options = []
    cluster_options << "--locale #{@new_resource.locale}" if @new_resource.locale 

    create_cluster = begin
                   "pg_createcluster #{cluster_options.join(' ')} #{cluster_version} #{cluster_name}"
                 end

    log "Creating postgresql cluster by #{create_cluster}"

    execute "create-cluster-#{cluster_version}-#{cluster_name}" do
      action :run
      user "root"
      command <<-EOH
        #{create_cluster}
      EOH
      not_if do
        ::File.exist?("#{config_file}")
      end
    end

    template config_file do
      source "postgresql.conf.erb"
      cookbook "postgresql"
      user "postgres"
      group "postgres"
      mode 0600
    end

    template hba_file do
      source "pg_hba.conf.erb"
      cookbook "postgresql"
      user "postgres"
      group "postgres"
      mode 0600
    end


    service "postgresql" do
      action [:start]
    end

    assign_postgres_password = bash "assign-postgres-password-#{cluster_name}-#{node.postgresql.config.port}" do
      user 'postgres'
      code <<-EOH
    echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{node.postgresql.password.postgres}';" | psql
      EOH
        #only_if 'pg_lsclusters -h | awk -F" " \'{ print $1 $2 }\' | grep "#{params[:name]}" | grep "#{version}"'
    #    only_if "/etc/init.d/postgresql status | grep #{cluster_name}" # make sure server is actually running
    #    not_if "echo '\\connect' | PGPASSWORD=#{node.postgresql.password.postgres} psql --username=postgres --no-password  -h #{node[:postgresql][:data_run]} -p #{node.postgresql.config.port} "
    #    action :nothing
    end


    postgresql_connection_info = {
      :host     => 'localhost',
      :port     => node['postgresql']['config']['port'],
      :username => 'postgres',
      :password => node['postgresql']['password']['postgres']
    }

    new_resource.databases.each do |db, item|
    
      postgresql_database_user item["user"] do
        connection postgresql_connection_info
        password node.postgresql.password[item["user"]]
        action :create
      end

      postgresql_database db do
        connection postgresql_connection_info
        owner item["user"]
        action :create
      end

      #postgresql_database "mydb user can create DB" do
      #  connection      postgresql_connection_info
      #  sql "alter role #{node.mydb.user} with createdb"
      #  action :query
      #end

    end

    service "postgresql" do
      action [:stop]
    end

  end
end


