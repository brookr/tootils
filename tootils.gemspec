# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tootils}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brook Riggio"]
  s.date = %q{2009-07-16}
  s.email = %q{brookr@brookr.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README",
     "Rakefile",
     "VERSION",
     "lib/tootils.rb",
     "test/test_helper.rb",
     "test/tootils_test.rb"
  ]
  s.homepage = %q{http://github.com/brookr/tootils}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Twitter Utilities}
  s.test_files = [
    "test/test_helper.rb",
     "test/tootils_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
