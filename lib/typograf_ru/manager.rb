# -*- encoding: utf-8 -*-
require "singleton"
module TypografRu
  class Manager
    include Singleton
    extend SingleForwardable

    def_delegators :instance, :register, :exec_for, :clear

    def register(klass, attr, options = {})
      mapping[klass]||= {}
      mapping[klass][attr] = options
    end

    def exec_for(object)
      return unless mapping[object.class].is_a?(Hash)

      mapping[object.class].each do |attr, options|
        next if options[:if].is_a?(Proc) && !options[:if].call(self)
        text = object.send(attr)
        if !text.nil? && !text.empty? && (options[:no_check] || object.send("#{attr}_changed?"))
          res = RestClient.post('http://typograf.ru/webservice/', :text => text, :chr => 'UTF-8')
          object.send("#{attr}=", res.force_encoding("UTF-8"))
        end
      end
    end

    def clear(klass = nil)
      if klass.nil?
        mapping.clear
      else
        mapping.delete(klass)
      end
    end

    def mapping
      @mapping ||= {}
    end
  end
end
