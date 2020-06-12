#!/usr/bin/env ruby

require 'erb'
require 'pathname'

@root_path = Pathname.new(File.expand_path('.', __dir__))
files_path = @root_path.join('files')

output = File.read(@root_path.join('template.src.rb'))

(Dir[files_path.join('**/*')] + Dir[files_path.join('**/.*')]).reject do |file|
  File.directory?(file)
end.each do |template|
  file_name = template.sub(files_path.to_s + '/', '')
  output << "file '#{file_name}', <<-DATA\n#{ERB.new(File.read(template)).result(binding).strip}\nDATA\n\n"
end

File.write(@root_path.join('dist/template.rb').to_s, output)

