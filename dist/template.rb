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

file 'config/brakeman.yml', <<-DATA
---
:run_all_checks: true
:rails3: true
:rails4: true
:rails5: true
:rails6: true
DATA

file 'config/initializers/bullet.rb', <<-DATA
# frozen_string_literal: true

if defined?(Bullet)
  Bullet.enable = true
  Bullet.bullet_logger = true
  Bullet.raise = Rails.env.test?
end
DATA

file 'config/initializers/performance.rb', <<-DATA
# frozen_string_literal: true

Oj.optimize_rails
DATA

file '.yamllint', <<-DATA
---
extends: default

rules:
  line-length:
    max: 120
DATA

file '.editorconfig', <<-DATA
# EditorConfig is awesome: http://EditorConfig.org

# top-most EditorConfig file
root = true

# Unix-style newlines with a newline ending every file
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 4

[*.{rb,yml}]
indent_size = 2
DATA

file '.overcommit.yml', <<-DATA
---
CommitMsg:
  ALL:
    enabled: false
PreCommit:
  ALL:
    on_warn: fail
  BrokenSymlinks:
    enabled: true
  BundleCheck:
    enabled: true
  BundleOutdated:
    enabled: true
  CaseConflicts:
    enabled: true
  DatabaseConsitency:
    enabled: true
    required_executable: database_consistency
  ExecutePermissions:
    enabled: true
    exclude:
      - "bin/*"
  Fasterer:
    enabled: true
  FixMe:
    enabled: true
  HardTabs:
    enabled: true
  LineEndings:
    enabled: true
  LocalPathsInGemfile:
    enabled: true
  Mdl:
    enabled: true
    command: ["bundle", "exec", "mdl"]
  MergeConflicts:
    enabled: true
  RailsBestPractices:
    enabled: true
  RailsSchemaUpToDate:
    enabled: true
  RuboCop:
    enabled: true
  RubySyntax:
    enabled: true
  TrailingWhitespace:
    enabled: true
  YamlLint:
    enabled: true
    flags: ['-s']
PrePush:
  Brakeman:
    enabled: true
    flags: ['--exit-on-warn', '--quiet', '--summary', '-c', 'config/brakeman.yml']
DATA

file '.rubocop.yml', <<-DATA
---
require:
  - rubocop-performance
  - rubocop-rails
  - rubocop-rspec

Layout/ClassStructure:
  Enabled: true

Layout/EmptyLinesAroundAttributeAccessor:
  Enabled: true

Layout/SpaceAroundMethodCallOperator:
  Enabled: true

Layout/LineLength:
  Max: 120

Lint/DeprecatedOpenSSLConstant:
  Enabled: true

Lint/MixedRegexpCaptureTypes:
  Enabled: true

Lint/RaiseException:
  Enabled: true

Lint/StructNewOverride:
  Enabled: true

Migration/DepartmentName:
  Enabled: true

Style/CollectionMethods:
  Enabled: true

Style/ConstantVisibility:
  Enabled: true

Style/Documentation:
  Enabled: false

Style/ExponentialNotation:
  Enabled: true

Style/HashEachMethods:
  Enabled: true

Style/ImplicitRuntimeError:
  Enabled: true

Style/InlineComment:
  Enabled: true
  Exclude:
    - config/boot.rb

Style/MethodCallWithArgsParentheses:
  Enabled: false

Style/ReturnNil:
  Enabled: true

Style/Send:
  Enabled: true

Style/StringHashKeys:
  Enabled: true
  Exclude:
    - config/environments/*.rb

Style/HashTransformKeys:
  Enabled: true

Style/HashTransformValues:
  Enabled: true

Style/RedundantRegexpCharacterClass:
  Enabled: true

Style/RedundantRegexpEscape:
  Enabled: true

Style/SlicingWithRange:
  Enabled: true

AllCops:
  TargetRubyVersion: 2.7
  DisplayCopNames: true
  Exclude:
    - 'bin/*'
    - 'engines/**/*'
    - 'db/schema.rb'
    - 'db/migrate/*.rb'
DATA

