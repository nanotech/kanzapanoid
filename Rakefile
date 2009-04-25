desc 'Generate doc files using rdoc and hanna'
task :doc do
	sh 'hanna', '-x(doc/|tests/)', '-U', '-w2', '-Whttp://github.com/nanotech/kanzapanoid/tree/master/'
end

require 'spec/rake/spectask'

desc "Run all tests with RCov"
Spec::Rake::SpecTask.new('coverage') do |t|
	t.spec_opts = ['-r', 'spec_helper']
	t.spec_files = FileList['spec/*_spec.rb']
	t.rcov = true
	t.rcov_opts = ['--exclude', 'tests/,spec,gems/']
end
