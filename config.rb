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

activate :blog

helpers do

  #
  # Layout helpers
  #

  # Image at the top of the page
  def post_top_image
    image_path data.page.top_image
  end

  def chapters( post )
    headers = File.readlines( post.source_file ).collect do |x|
      if x =~ /^\#{1,6}\s(.*)/
        $1
      else
        nil
      end
    end.compact


    case markdown_engine
    when :redcarpet
      headers.map { |x| [x, x.downcase.gsub( /\s/, "-" )] }
    when :kramdown
      headers.each_with_index.map { |x,i| [x,i == 0 ? "section" : "section-#{i}"] }
    else
      []
    end
  end

  def image_caption(image, text)
    %{<figure>
      #{image_tag image}
      <figcaption> #{text} </figcaption>
   </figure>}
  end

  def page_active?(urls)
    Array(urls).each do |url|
      return true if current_page.url.split("/").last == url.split("/").last
    end
    false
  end

  def active_class(url)
    "active" if page_active?(url)
  end
end

# set :markdown, tables: true, autolink: true, gh_blockcode: true, fenced_code_blocks: true, with_toc_data: true, smart: true
# set :markdown_engine, :redcarpet

set :markdown_engine, :kramdown
set :markdown, :layout_engine => :erb,
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
  activate :asset_hash
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
