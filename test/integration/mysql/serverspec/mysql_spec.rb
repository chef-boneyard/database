require 'spec_helper'

describe('mysql_database_test::default') do
  describe command("echo 'SHOW SCHEMAS;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3 | grep databass") do
    its(:exit_status) { should eq 0 }
  end

  describe command("echo 'SHOW SCHEMAS;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3 | grep datatrout") do
    its(:exit_status) { should eq 1 }
  end

  describe command("echo 'select User,Host from mysql.user;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3 | grep fozzie") do
    its(:exit_status) { should eq 0 }
  end

  describe command("echo 'select User,Host from mysql.user;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3 | grep kermit") do
    its(:exit_status) { should eq 1 }
  end

  describe command("echo 'select Password from mysql.user where User like \"fozzie\" \\G;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3") do
    its(:stdout) { should contain /Password: \*EF112B3D562CB63EA3275593C10501B59C4A390D/ }
  end

  describe command("echo 'select Password from mysql.user where User like \"moozie\" \\G;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3") do
    its(:stdout) { should contain /Password: \*F798E7C0681068BAE3242AA2297D2360DBBDA62B/ }
  end

  describe command("echo 'show tables;' | /usr/bin/mysql -u moozie -h 127.0.0.1 -P 3306 -pzokkazokka databass") do
    its(:exit_status) { should eq 0 }
  end

  describe command("echo 'select Password from mysql.user where User like \"rowlf\" \\G;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3") do
    its(:stdout) { should contain /Password: \*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9/ }
  end

  describe command("echo 'select Password from mysql.user where User like \"statler\" \\G;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3") do
    its(:stdout) { should contain /Password: \*2027D9391E714343187E07ACB41AE8925F30737E/ }
  end

  describe command("echo 'select Password from mysql.user where User like \"rizzo\" \\G;' | /usr/bin/mysql -u root -h 127.0.0.1 -P 3306 -pub3rs3kur3") do
    its(:stdout) { should contain /Password: \*125EA03B506F7C876D9321E9055F37601461E970/ }
  end
end
