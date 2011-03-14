# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gotta_have}
  s.version = "0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nate Delage"]
  s.date = %q{2011-03-14}
  s.description = %q{Check for specific versions of cmd line utilities as dependencies}
  s.email = %q{nate@natedelage.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/gotta_have.rb", "lib/gotta_have/cmd_line_helpers.rb", "lib/gotta_have/dependency_checker.rb", "lib/gotta_have/exceptions.rb"]
  s.files = ["README.rdoc", "Rakefile", "gotta_have.gemspec", "lib/gotta_have.rb", "lib/gotta_have/cmd_line_helpers.rb", "lib/gotta_have/dependency_checker.rb", "lib/gotta_have/exceptions.rb", "test/dependency_checker_test.rb", "test/test_helper.rb", "Manifest"]
  s.homepage = %q{http://github.com/ndelage/gotta_have}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Gotta_have", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gotta_have}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Check for specific versions of cmd line utilities as dependencies}
  s.test_files = ["test/dependency_checker_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<open4>, [">= 0"])
      s.add_runtime_dependency(%q<versionomy>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
    else
      s.add_dependency(%q<open4>, [">= 0"])
      s.add_dependency(%q<versionomy>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<open4>, [">= 0"])
    s.add_dependency(%q<versionomy>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
  end
end
