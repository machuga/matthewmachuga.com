require 'ostruct'
###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

page "/contact.html"

page "/screencasts.html" do
  screencasts = YAML.load_file('./screencasts.yml').map { |series| OpenStruct.new series }
  @series  = screencasts.select { |c| c.type == 'series' }
  @singles = screencasts.select { |c| c.type == 'single' }
end

page "/talks.html" do
  @talks = YAML.load_file('./talks.yml').map { |talk| OpenStruct.new talk }
end

page "blog/feed.xml", layout: false

activate :blog do |blog|
  blog.prefix = "blog"
  blog.layout = "blog"
  blog.permalink = "{year}/{title}.html"
  blog.sources = "{year}/{title}.html"
  blog.taglink = "tags/{tag}.html"
  #blog.summary_separator = /(READMORE)/
  blog.summary_length = 75
  blog.year_link = "{year}.html"
  #blog.month_link = "{year}/{month}.html"
  #blog.day_link = "{year}/{month}/{day}.html"

  blog.tag_template = "blog/tag.html"
  blog.calendar_template = "blog/calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/{num}"
end

with_layout :layout do
   page "blog/2014.html"
end

with_layout :blog do
   page "blog/2014/*"
end

with_layout :archive do
   page "/blog/tags/*"
end
###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
activate :livereload
# end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

helpers do
  def current_page?(uri)
    request.path.start_with? uri.sub('/', '')
  end

  def site_info
    OpenStruct.new(
      author: 'Matthew Machuga',
      email: 'machuga@gmail.com',
      description: 'Lorem ipsum'
    )
  end

  def navigation
    {
      blog: '/blog',
      contact: '/contact.html',
      screencasts: '/screencasts.html',
      talks: '/talks.html',
    }
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end
