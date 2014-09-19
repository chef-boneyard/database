source 'https://api.berkshelf.com'

metadata

cookbook "postgresql", git: "https://github.com/sinfomicien/postgresql.git", branch: "fix-debian-not-installing-directories"

group :integration do
  cookbook 'test', :path => './test/fixtures/cookbooks/test'
end
