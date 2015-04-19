# -*- coding: utf-8 -*-
require 'slim'
Slim::Engine.disable_option_validator!

#$. << "./lib"
require "#{File.dirname(__FILE__)}/lib/products"
require "#{File.dirname(__FILE__)}/lib/data_folders"

I18n.enforce_available_locales = true
# general settings
set :encoding, 'utf-8'
set :index_file, 'index.html'
set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'
set :partials_dir, 'partials'
set :haml, { :format => :html5 }

ignore '*.less'

# don't precompile assets when middleman startup, but only when it's requested.
#set :debug_assets, true

activate :livereload

activate :i18n, langs: [:ja, :en, :uk]

activate :directory_indexes

page '/', layout: 'layout'

set :markdown, :tables => true, :autolink => true, :gh_blockcode => true, :fenced_code_blocks => true, :with_toc_data => true
set :markdown_engine, :redcarpet

configure :development do
  activate :relative_assets
end

# --------------------------------------------
# Localization helpers
# --------------------------------------------
helpers do

  # Print content tag only if text present
  def tag_if(text, tag, alternative_text=nil)
    if text.blank?
      content_tag(tag, alternative_text) if alternative_text
    else
      content_tag(tag, text)
    end

  end

  def current_language
    data.languages[I18n.locale]
  end

  def available_locales_as_regex
    I18n.config.available_locales.map(&:to_s).join("|")
  end

  def current_without_locale
    current_page.url
    .sub(%r{^/(#{ available_locales_as_regex})/},'/')
  end

  def current_with_locale(locale)
    if locale == I18n.default_locale.to_s
      current_without_locale
    else
      "/#{locale}/#{current_without_locale}"
    end
      .gsub(%r{/+}, "/")
  end

  # Translate strings that are not part of /locale/ directory.
  def l(key, split: false)
    string = ((key.is_a?(Hash) ? key[I18n.locale.to_s] : key) || "")
    if split
      string.gsub(/\n+/, "<p>")
    else
      string
    end
  end

  def locale_prefix(locale=I18n.locale)
    if locale == I18n.default_locale
      "/"
    else
      "/#{locale.to_s}"
    end
  end

  def localized_href(href)
    "/#{locale_prefix}/#{href}".gsub(%r{/+}, "/")
  end

end

helpers do
  def products_item_link(item)
    "<a href='#{localized_href item.url}'>#{item.basename.to_i}</a>"
  end
end

activate :products
activate :data_folders, namespace: 'events'

# --------------------------------------------
# Generated dynamic pages
# --------------------------------------------
[ :ja, :en, :uk].each do |lang|
  pref = (lang == :ja) ? "" : "/#{lang}"

  # --------------------------------------------
  # DataFolders - Events
  # --------------------------------------------
  events.values.each do |event|
    proxy "#{pref}/event/#{event.index}.html", "event.html", locals: {event: event}, ignore: true do
      ::I18n.locale = lang
    end
  end

  # --------------------------------------------
  # Products is Pysanka products lister
  # --------------------------------------------
  Products::Items.list.each do |dir|
    item = ::Products::Item.new(dir)
    proxy "#{pref}/#{item.url}.html", "product.html", locals: { item: item}, ignore: true do
      ::I18n.locale = lang
    end
  end

end
# --------------------------------------------

configure :build do
  activate :relative_assets
  # activate :directory_indexes
  activate :sprockets
  activate :minify_css
  activate :minify_javascript
  # somehow minifying html takes some html attributes away so it is causing
  # some css not applied to certain elements... so until we find alternative
  # way to monify html, we will disable this
  #activate :minify_html
  activate :asset_hash
  #activate :gzip
  ignore 'product.html'
  ignore(/Icon\r$/)
  ignore(/\.DS_Store/)
  ignore(/^assets.*\.yml/)
  ignore(/^assets\/stylesheets\/(?!all).*\.css/)
  ignore(/^assets\/javascripts\/(?!all).*\.js/)
  ignore(%r{^assets/stylesheets/colorschemas/.*})
  ignore(%r{^assets/images/homepage-slider/pysanka-.*\.jpg$})
  ignore(%r{/src/})


  # if ENV['CDN_HOST']
  #   activate :asset_host
  #   set :asset_host, ENV['CDN_HOST']
  # end
end
