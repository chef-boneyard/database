#
# Author:: Ronald Doorn (<rdoorn@schubergphilie.com>)
#
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Install required packages
case node['platform_family']
when 'rhel', 'fedora'
  packages = ['gcc', 'make', 'sqlite-devel', 'sqlite']
when 'debian', 'ubuntu'
  packages = ['gcc', 'make', 'libsqlite3-dev', 'sqlite3']
end

package packages

# Install required gem (will be compiled)
chef_gem 'sqlite3' do
  compile_time false
end
