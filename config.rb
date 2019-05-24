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

set :url_root, 'http://dmytro.github.io/vytrishky'
activate :search_engine_sitemap

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
  blog.layout = "post"
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

  # Use tag translation if available, or original tag otherwise
  def tag_text(tag)
    data.tags[tag.downcase] || tag
  end

  # Try to find image in the backgrounds folder with the name same as
  # current filename, and .jpg
  def intro_background_by_current_filename
    image = current_path.sub(/\.html$/,'.jpg')
    prefix = "assets/images/backgrounds/"

    if file = sitemap.resources.find { |x| x.path =~ %r{#{prefix}#{image}}}
      file.path.sub(/^assets\/images\//, '')
    else
      data.page.intro.image rescue ""
    end
  end

  def intro_background_by(article)
    sitemap
        .resources
        .find{
        |x| x.path ==
          [
          images_dir,
          basepath_by(article),
          article.data.intro.image
          ].compact.join("/")
      }
  end


  #
  # For link to article use like
  #
  # `link_to 'title', article_by_title('title')`
  #
  def article_by_title(title)
    blog.articles.find { |article| article.title.downcase == title.downcase }
  rescue
    nil
  end

  def link_to_article(title)
    link_to title, article_by_title(title)
  end

  def basepath_by(article)
    article.data.images.basepath rescue nil
  end
  #
  # Layout helpers
  #

  # Build weighted tag cloud.
  # Return: array [tag_name, size]
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


  # ------------------------------------------------------------------
  #
  # All related to article series
  #
  # ------------------------------------------------------------------

  # Find all articles that have `series` in YAML frontmatter with the
  # same value as in the current article.
  def all_with_series
    blog.articles.find_all {|x| x.data.has_key? 'series' }
  end

  # Return all posts that have data.series == 'String'
  def with_series(series)
    all_with_series.find_all { |art| art.data.series == series }
  end

  # Array of (String) names of series in the blog.
  def all_series
    all_with_series.map(&:data).map{ |x| x['series'] }.uniq
  end

  def series_with_a_title(title)
    blog
      .articles
      .find_all {|y| y.data['series'] == title}
  end

  # Array of 1st post in each series.
  def series_links
    all_series.map{ |x|
      series_with_a_title(x)
        .sort{ |a,b| a.destination_path <=> b.destination_path }
        .first
    }
  end


  # ------------------------------------------------------------------
  #
  # Widgets
  #
  # ------------------------------------------------------------------

  def youtube(id: "", title: "")
    video source: :youtube, id: id, title: title
  end

  def vimeo(id: "", title: "")
    video source: :vimeo, id: id, title: title
  end

  def video(id: "", title: "", source: :youtube, &block)
    partial "video_card",
      locals: {  title: title, id: id, source: source }
  end

  def floating_quote(text = "", &block)
    partial :float_quote do
      block_given? ? yield : text
    end
  end

  # CSS filters applied to images in dividers and intro.
  def default_filters
    data.page.filters || ["sepia-40", "vignette-90"]
  end

  # Widget 'photo' - card layout.
  def photo(
    pictures,
    caption: "",
    filters: default_filters,
    layout: :landscape,
    position: nil,
    &block
  )
    partial_name = Array(pictures).count == 1 ? :photo : :photos3
    partial partial_name,
      locals: {
               caption: caption,
               pictures: pictures,
               filters: filters,
               layout: layout,
               position: position
              } do
      block_given? ? yield : ""
    end
  end

  alias :photos3 :photo

  def youtube(video)
    partial :youtube, locals: { video: video }
  end

  def gallery(pictures, caption: "", **params, &block)
    partial :gallery, locals: { caption: caption, pictures: Array(pictures) }.merge(**params) do
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
  # def post_image_link(image)
  #   image_link post_image image
  # end

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

  # pretty queoted text
  def q text
    "«#{ text }»"
  end

  def Q text
    "„#{ text }“"
  end

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
  set :base, ""
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
  ignore '*_template.*'
  ignore(/Icon\r$/)
  ignore(/\.DS_Store/)
  ignore(/^assets.*\.yml/)
  ignore(/^assets\/stylesheets\/(?!all).*\.css/)
  ignore(/^assets\/javascripts\/(?!all).*\.js/)
  ignore(%r{^assets/stylesheets/colorschemas/.*})
  ignore(%r{/src/})
  ignore(%r{/TODO/})
  ignore(%r{^assets\/images\/watermark\.png})


  # if ENV['CDN_HOST']
  #   activate :asset_host
  #   set :asset_host, ENV['CDN_HOST']
  # end
end
