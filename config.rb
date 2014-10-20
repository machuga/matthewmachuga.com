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
    request.path_info == uri
  end

  def site_info
    OpenStruct.new(
      author: 'Matthew Machuga',
      email: 'machuga@gmail.com',
      description: 'Lorem ipsum'
    )
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
