module ToRssHelper
  def rss_link_tag(title, url)
    tag "link", {:title => title, :type => "application/rss+xml", :rel => "alternate", :href => url }
  end
end