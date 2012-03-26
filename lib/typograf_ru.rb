require "typograf_ru/version"
require "typograf_ru/manager"

module TypografRu
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods

    def typografy(attr, options={})
      include InstanceMethods

      options ||= {}
      Manager.register(self, attr, options)

      before_save :typografy_before_save
    end
    
    def disable_typografy!
      Manager.clear(self)
    end  
  end

  module InstanceMethods
    def typografy_before_save
      Manager.invoke(self)
    end
  end
end

ActiveRecord::Base.send(:include, TypografRu) if defined?(ActiveRecord)
