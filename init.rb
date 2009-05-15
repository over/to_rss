# Include hook code here
require 'active_record'
require 'action_controller'
require 'action_view'
require 'rss/2.0'
require 'rss/maker'

require File.join(File.dirname(__FILE__), '/lib/to_rss')

ActiveRecord::Base.send(:include, ToRss)
ActionController::Base.send(:include, ToRss)