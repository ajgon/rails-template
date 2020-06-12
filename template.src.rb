@root_path = Pathname.new(File.expand_path('.', __dir__))
files_path = @root_path.join('files')

gem 'fast_blank'
gem 'oj'

gem_group :development, :test do
  gem 'bullet'
  gem 'isolator'
  gem 'pry-rails'
  gem 'rspec-rails'
end

gem_group :development do
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'database_consistency'
  gem 'fasterer'
  gem 'mdl'
  gem 'overcommit'
  gem 'rails_best_practices'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'solargraph'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-rubocop'
  gem 'spring-watcher-listen'
  gem 'strong_migrations'
  gem 'strong_versions'
end

gem_group :test do
  gem 'factory_bot'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'webmock'
end

inside 'config/environments' do
  File.write('development.rb', File.read('development.rb').sub(%('tmp', 'caching-dev.txt'), %('tmp/caching-dev.txt')))
  File.write('production.rb', File.read('production.rb').sub(%r{#.*config.force_ssl}, 'config.force_ssl'))
end

environment 'config.force_ssl = true', env: 'production'

inside '.' do
  Dir['**/*.yml'].reject do |yml|
    File.read(yml).split("\n").reject do |line|
      line.strip.start_with?('#')
    end.reject(&:empty?).first.start_with?('---')
  end.each do |yml|
    File.write(yml, File.read(yml).prepend("---\n"))
  end
end

after_bundle do
  generate 'rspec:install'
  run 'rm -rf test'
  run 'bundle exec rubocop --auto-correct'
  git :init
  git add: '.'
  git commit: '-a -m "Initial commit"'
  run 'bundle exec overcommit --install'
  run 'bundle exec overcommit --sign'
  run 'bundle exec overcommit --sign pre-commit'
end

