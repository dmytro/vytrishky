# -*- coding: utf-8 -*-
require 'slim'
Slim::Engine.disable_option_validator!

require 'pry'

I18n.enforce_available_locales = true
# general settings
set :encoding, 'utf-8'
set :index_file, 'index.html'
set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'
set :partials_dir, 'partials'

activate :livereload

activate :directory_indexes
activate :i18n, langs: [:uk, :en]

activate :disqus do |d|
  d.shortname = 'vytrishky'
end

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  # blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  blog.page_link = "page/{num}"
end


helpers do

  def custom_intro_background
    image = "#{current_page.path.sub(/\.html$/,'')}.jpg"
    prefix = "assets/images/backgrounds/"

    if file = sitemap.resources.find { |x| x.path =~ %r{#{prefix}#{image}}}
      file.path.sub(/^assets\/images\//, '')
    else
      data.page.intro.image
    end
  end
  #
  # Layout helpers
  #
  def with_series(series)
    all_with_series.find_all { |art| art.data.series == series }
  end

  def tag_cloud
    size_min, size_max = 12.0, 30.0

    counts = blog.tags.map do |tag, posts|
      [tag, posts.count]
    end

    min, max = counts.map(&:last).minmax

    weight = counts.map do |name, count|
      # logarithmic distribution
      weight = (Math.log(count) - Math.log(min))/(Math.log(max) - Math.log(min))
      [name, weight]
    end

    weight.sort_by! { rand }

    weight.map do |tag|
      name, weight = tag
      size = size_min + ((size_max - size_min) * weight).to_f
      [name, size]
    end
  end

  # Facebook fails to parse Open Graph page image url tag og:image
  # unless it's full http://.... format. Local relative libks are not
  # accepted.
  def og_image_path
    a = data.page.intro.image
    b = post_image_path(a)
    c = b.sub(/^(.*)(\/assets\/images\/.*)$/, '\2')
      .gsub(/\/+/, '/')
      .sub(/\/*/,'')
    "#{data.site.base_url}/#{c}"
  end

  # Find all articles that have `series` in YAML frontmatter with the
  # same value as in the current article.
  def all_with_series
    blog.articles.find_all {|x| x.data.has_key? 'series' }
  end

  # CSS filters applied to images in dividers and intro.
  def default_filters
    ["sepia-40", "vignette-90"]
  end

  def photo(pictures, filters: default_filters, layout: :landscape, position: nil, &block)
    partial_name = Array(pictures).count == 1 ? :photo : :photos3
    partial partial_name, locals: {pictures: pictures, filters: filters, layout: layout, position: position} do
      block_given? ? yield : ""
    end
  end

  alias :photos3 :photo

  def gallery(pictures, **params, &block)
    partial :gallery, locals: { pictures: Array(pictures) }.merge(**params) do
      block_given? ? yield : ""
    end
  end

  def chapter
    partial :chapter do
      block_given? ? yield : ""
    end
  end

  def divider(image, **params, &block)
    partial :divider, locals: {image: image}.merge(**params) do
      block_given? ? yield : ""
    end
  end

  def pull_left(content, left_column=4, **params)
    partial :pull_left, locals: { content: content}
      .merge({left_column: left_column, right_column: (12 - left_column)})
      .merge(**params) do
      block_given? ? yield : ""
    end
  end


  def pull_right(content, right_column=4, **params)
    partial :pull_right, locals: { content: content}
      .merge({right_column: right_column, left_column: (12 - right_column)})
      .merge(**params) do
      block_given? ? yield : ""
    end
  end

  def google_map(url, **params)
    partial :google_map, locals: { url: url }.merge(**params) do
      block_given? ? yield : ""
    end
  end
  # Shorten img file list.
  # Convert list of %w{11 22 33} -> ["IMG_11.jpg", ...]
  def imgs(list)
    Array(list).map{ |x| "IMG_#{x}.jpg" }
  end

  # Image at the top of the page
  def post_top_image
    image_path data.page.top_image
  end

  # Merge image file name with prefix from YAML data
  # `data.page.images.basepath`
  def post_image(image)
    prefix = data.page.images.basepath rescue ''
    [prefix, image].join("/").sub(/^\//,'')
  end

  # Same as image_path with prepended prefix
  def post_image_path(image)
    image_path(post_image(image))
  end

  # Same as image_link with prepended prefix
  def post_image_link(image)
    image_link post_image image
  end

  # Not used here
  # def chapters( post )
  #   headers = File.readlines( post.source_file ).collect do |x|
  #     if x =~ /^\#{1,6}\s(.*)/
  #       $1
  #     else
  #       nil
  #     end
  #   end.compact


  #   case markdown_engine
  #   when :redcarpet
  #     headers.map { |x| [x, x.downcase.gsub( /\s/, "-" )] }
  #   when :kramdown
  #     headers.each_with_index.map { |x,i| [x,i == 0 ? "section" : "section-#{i}"] }
  #   else
  #     []
  #   end
  # end


end

# set :markdown, tables: true, autolink: true, gh_blockcode: true, fenced_code_blocks: true, with_toc_data: true, smart: true
# set :markdown_engine, :redcarpet

set :markdown_engine, :kramdown
set :markdown, :layout_engine => :slim,
  :tables => true,
  :autolink => true,
  footnotes: true,
  :smartypants => true,
  smart_quotes: [180, 180, 8222, 8220]

configure :development do
  set :base, ""
  activate :relative_assets
end

configure :build do
  set :base, "/vytrishky"
  activate :relative_assets
  # activate :directory_indexes
  activate :sprockets
  activate :minify_css
  activate :minify_javascript
  set :relative_links, true

  activate :disqus do |d|
    d.shortname = 'vytrishky'
  end

  # somehow minifying html takes some html attributes away so it is causing
  # some css not applied to certain elements... so until we find alternative
  # way to monify html, we will disable this
  activate :minify_html do |html|
    html.remove_multi_spaces        = true   # Remove multiple spaces
    html.remove_comments            = true   # Remove comments
    html.remove_intertag_spaces     = false  # Remove inter-tag spaces
    html.remove_quotes              = true   # Remove quotes
    html.simple_doctype             = false  # Use simple doctype
    html.remove_script_attributes   = false   # Remove script attributes
    html.remove_style_attributes    = false   # Remove style attributes
    html.remove_link_attributes     = false   # Remove link attributes
    html.remove_form_attributes     = false  # Remove form attributes
    html.remove_input_attributes    = false   # Remove input attributes
    html.remove_javascript_protocol = false   # Remove JS protocol
    html.remove_http_protocol       = false   # Remove HTTP protocol
    html.remove_https_protocol      = false  # Remove HTTPS protocol
    html.preserve_line_breaks       = false  # Preserve line breaks
    html.simple_boolean_attributes  = true   # Use simple boolean attributes
  end
  activate :asset_hash, :ignore => [/fonts/, /favicon.png/]
  activate :gzip
  ignore '*.less'
  ignore(/Icon\r$/)
  ignore(/\.DS_Store/)
  ignore(/^assets.*\.yml/)
  ignore(/^assets\/stylesheets\/(?!all).*\.css/)
  ignore(/^assets\/javascripts\/(?!all).*\.js/)
  ignore(%r{^assets/stylesheets/colorschemas/.*})
  ignore(%r{/src/})


  # if ENV['CDN_HOST']
  #   activate :asset_host
  #   set :asset_host, ENV['CDN_HOST']
  # end
end
