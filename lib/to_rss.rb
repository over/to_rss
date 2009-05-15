class ActionController::Base  
  alias_method :render_normal, :render
  
  def render(options = nil, extra_options = {}, &block)
    if options && options.is_a?(Hash) && rss = options[:rss]
      response.content_type ||= Mime::RSS
      block ? render_for_text(rss[:items].to_rss(rss[:options], &block)) : render_for_text(rss)
    else
      render_normal(options, extra_options, &block)
    end
  end
  
end

module ActiveSupport
  module CoreExtensions
    module Array
      module Conversions
        def to_rss(options={}, &block)
          ::ToRss.build(self, options, &block)
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

  
  def self.generate_rss(items, options, &block)
    content = ::RSS::Maker.make('2.0') do |m|
      m.channel.title = options[:feed_title] || ToRss::Config.feed[:title]
      m.channel.link  =  options[:feed_link] || ToRss::Config.feed[:link]
      m.channel.description = options[:feed_description] || ToRss::Config.feed[:description]
      
      items.each do |item|
        feed = Hash.new
        block.call(feed, item)

        item_options = {
          :title => feed[:title] || item.title || item.name || item.lead || item.heading,
          :link => link, # || m.channel.link,
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
    return content.to_s
  end

  def self.build(items, options, &block)
    if block
      generate_rss(items, options, &block)
    else
      { :items => items, :options => options }
    end
  end
end