rails-template
==============

Rails template for scaffolding new apps.

To invoke:

```command
rails new -m https://raw.githubusercontent.com/ajgon/rails-template/master/dist/template.rb <other args> <app name>
```

## Development

Add necessary changes to [template.src.rb](template.src.rb), and then invoke:

```shell
ruby build.rb
```

A new template will be generated in [dist/template.rb](dist/template.rb).
