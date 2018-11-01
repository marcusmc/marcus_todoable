Gem::Specification.new do |s|
    s.name        = 'Todoable'
    s.version     = '0.0.0'
    s.date        = '2018-10-31'
    s.summary     = "A Wrapper for the Todoable API"
    s.description = "Provides a straightforward wrapping mechanism for the Todoable API provided by Teachable"
    s.authors     = ["Marcus McLaughlin"]
    s.email       = 'marcucs.mc@mgail.com'
    s.files       = ["lib/todoable.rb", "lib/todoable/todoable_error.rb"]
    s.add_development_dependency "rspec"
    s.add_development_dependency "vcr"
    s.add_development_dependency "webmock"
    s.add_development_dependency "timecop"
    s.add_dependency "httparty"
    s.license       = 'MIT'
  end