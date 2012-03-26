require "typograf_ru/version"

module TypografRu
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods

    def typografy(attr, options={})
      include InstanceMethods

      options ||= {}
      inheritable_attributes[:typografy_fields] = {} if typografy_fields.nil?
      
      typografy_fields[attr] = options

      before_save :typografy_before_save
    end
    
    def typografy_fields
      inheritable_attributes[:typografy_fields]
    end
    
    def disable_typografy!
      inheritable_attributes[:disable_tipografy] = true
    end  

    def typografy_enabled?
      !inheritable_attributes[:disable_tipografy]
    end

  end

  module InstanceMethods
    def typografy_before_save
      perform_typografy!
    end

    def perform_typografy!
      unless self.class.typografy_fields.nil?
        self.class.typografy_fields.each do |attr, options|
          next if options[:if].is_a?(Proc) && !options[:if].call(self)
          text = send(attr)

          if self.class.typografy_enabled? && !text.blank? && ( send("#{attr}_changed?".to_sym) || options[:no_check] )
            begin
              res = RestClient.post('http://typograf.ru/webservice/', :text => text, :chr => 'UTF-8')
              write_attribute(attr, res)
            rescue
              logger.error('ERROR: Could not connect typograf!')
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, TypografRu) if defined?(ActiveRecord)
