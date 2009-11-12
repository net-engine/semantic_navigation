require 'rubygems'
require 'action_view'
require 'active_support'

module SemanticMenu
  mattr_accessor :active_class
  @@active_class = 'active'
  
  class Base
    include ActionView::Helpers::TagHelper, ActionView::Helpers::UrlHelper
    
    cattr_accessor :controller
    
    attr_accessor :items
    
    def initialize
      @items = []
    end
    
    def empty?
      @items.empty?
    end
    
    def to_s
      items.join("\n")
    end
  end
  
  class Item < Base
    attr_reader :url, :title

    def initialize(title, url, html_options = {})
      super()
      @title, @url, @html_options = title, url, html_options
    end

    def add(title, url, html_options = {}, &block)
      returning(Item.new(title, url, html_options)) do |item|
        @items << item
        yield item if block_given?
      end
    end

    def to_s
      options = {}
      options[:class] = SemanticMenu::active_class if active?
      children = super
      children = content_tag :ul, children unless empty?
      content_tag :li, link_to(@title, @url, @html_options) + children, options
    end

    def active?
      begin
        if @@controller
          url_string = CGI.unescapeHTML(url_for(@url))
          request = @@controller.request
          if url_string.index("?")
            request_uri = request.request_uri
          else
            request_uri = request.request_uri.split('?').first
          end
          
          request_uri = "#{request.protocol}#{request.host_with_port}#{request_uri}" if url_string =~ /^\w+:\/\//
          if url_string =~ /^(\w+:\/\/[^\/]*|)\/?$/ or url_string == ''
            url_string == request_uri
          else
            !Regexp.new("^#{Regexp.escape(url_string)}").match(request_uri).nil?
          end
        else
          false
        end
      end || @items.any?(&:active?)
    end
  end
  
  class Menu < Item
    undef :url, :title, :active?
    
    def initialize(controller, options = {}, &block)
      @@controller, @items = controller, []
      @options = {:class => 'semantic-menu'}.merge options
      
      yield self if block_given?
    end
    
    def to_s
      empty?? '' : content_tag(:ul, items.join("\n"), @options)
    end
  end
end
