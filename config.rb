# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true
activate :syntax, line_numbers: false

activate :autoprefixer do |prefix|
  prefix.browsers = 'last 2 versions'
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

page 'blog/feed.xml', layout: false

activate :blog do |blog|
  blog.prefix = 'blog'
  blog.layout = 'blog'
  blog.permalink = '{year}/{title}.html'
  blog.sources = '{year}/{title}.html'
  blog.taglink = 'tags/{tag}.html'
  # blog.summary_separator = /(READMORE)/
  blog.summary_length = 75
  blog.year_link = '{year}.html'
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"

  blog.tag_template = 'blog/tag.html'
  blog.calendar_template = 'blog/calendar.html'

  # Enable pagination
  blog.paginate = true
  blog.per_page = 25
  blog.page_link = 'page/{num}'
end

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

helpers do
  def site_info
    data.site_info
  end

  def current_title
    current_article&.title || current_page.data.title
  end
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end
