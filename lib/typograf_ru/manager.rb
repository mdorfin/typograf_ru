# -*- encoding: utf-8 -*-
module TypografRu
  class Manager
    class_attribute :mapping
    def self.register(klass, attr, options = {})
      mapping||= {}
      mapping[klass]||= {}
      mapping[klass][attr] = options
    end

    def self.invoke(object)
      mapping[object.class].each do |attr, options|
        next if options[:if].is_a?(Proc) && !options[:if].call(self)
        text = object.send(attr)
        if !text.empty? && (options[:no_check] || object.send("#{attr}_changed?"))
          res = RestClient.post('http://typograf.ru/webservice/', :text => text, :chr => 'UTF-8')
          object.send("#{attr}=", res)        
        end
      end      
    end

    def self.clear(klass)
      mapping[klass] = nil
    end
  end
end