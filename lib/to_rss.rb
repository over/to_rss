class ActionController::Base
  alias_method :render_without_rss, :render
  
  def render(options = nil, extra_options = {}, &block)
    if rss = options[:rss]
      response.content_type ||= Mime::RSS
      render_for_text(rss.respond_to?(:to_rss) ? rss.to_rss : rss, options[:status])
    else
      render_without_rss(options, extra_options, &block)
    end
  end
end

module ActiveSupport
  module CoreExtensions
    module Array
      module Conversions
        def to_rss(options={})
          ::ToRss.build(self, options)
        end
      end
    end
  end
end

module ToRss
  def self.included(base)
    base.extend ClassMethods
  end

  module Config
    @@feed = {
      :title => "Channel Title",
      :link => "",
      :description => "Channel description"
    }
    mattr_reader :feed
  end

  module ClassMethods
  end
  
  module SingletonMethods
  end

  module InstanceMethods
  end

  def self.build(items, options)
    content = ::RSS::Maker.make('2.0') do |m|
      m.channel.title = options[:feed_title] || ToRss::Config.feed[:title]
      m.channel.link  =  options[:feed_link] || ToRss::Config.feed[:link]
      m.channel.description = options[:feed_description] || ToRss::Config.feed[:description]
      
      items.each do |item|
        feed = Hash.new
        options[:makeup].call(feed, item)
        
        item_options = {
          :title => feed[:title] || item.title || item.name || item.lead || item.heading,
          :link => feed[:link],
          :description => feed[:description] || item.description || item.body || item.contents,
          :date => feed[:date] || Time.parse(item.created_at.to_s)
          
        }
        
        i = m.items.new_item
        i.title = item_options[:title]
        i.link = item_options[:link]
        i.description  = item_options[:description]
        i.date         = item_options[:date]
        i.guid.content = item_options[:link] + "#" + Digest::MD5.hexdigest("#{item_options[:title]}#{item_options[:description]}")
      end
    end
    
    content.to_s
  end
end