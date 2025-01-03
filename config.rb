require 'bundler'

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

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
  # @param games [Array<EnhancedHash>]
  # @param type [#to_s] ttrpg | video_game | other
  def select_games(games, type)
    case type.to_s
    when 'ttrpg'
      games.select { |g| g['type']&.casecmp? 'ttrpg' }
    when 'video_game'
      games.select { |g| g['type']&.casecmp? 'video_game' }
    when 'other'
      games.reject { |g| %w[ttrpg video_game].include? g['type']&.downcase }
    else
      raise StandardError, "Invalid type #{type} param when calling select_games helper"
    end
  end

  # @param font_file [String]
  def font_path(font_file)
    asset_path('fonts', font_file).delete_suffix('.fonts')
  end
end

# @return [String] calder version number
def version()
  Time.now.strftime("%Y.%m.%d") + '-' + `git log --format="%H" -n 1`[0...3]
rescue
  Time.now.strftime("%Y.%m.%d")
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings
set :port, 3000

# Create website in public/ folder
set :build_dir, 'public'

## Development Environment
configure :development do

  config[:development] = true
  config[:version] = version

  Bundler.require(:default, :development)

  activate :external_pipeline,
    name: 'data-images',
    command: 'cp -r data/images source/images/data',
    source: 'source/images/data',
    latency: 1

  activate :external_pipeline,
    name: 'esbuild',
    command: 'npm run start',
    source: 'tmp/esbuild/',
    latency: 1

  activate :livereload

end

## Build (Production) Environment
configure :build do

  config[:development] = false
  config[:version] = version

  activate :minify_css

  activate :external_pipeline,
    name: 'data-images',
    command: 'cp -r data/images source/images/data',
    source: 'source/images/data',
    latency: 1

  activate :external_pipeline,
    name: 'esbuild',
    command: 'npm run build',
    source: 'tmp/esbuild/',
    latency: 1

  activate :asset_hash

end
