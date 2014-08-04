actions :init
default_action :init

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :databases, :kind_of => Hash, :required => true

attr_accessor :exists
