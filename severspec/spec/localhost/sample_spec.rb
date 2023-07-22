require 'spec_helper'

#Gitがインストールされているか
describe package('git') do
  it { should be_installed }
end

#Rubyが指定のバージョンか
describe command('ruby -v') do
  its(:stdout) { should match /ruby 3\.1\.2/ }
end

#Bundlerが指定のバージョンか
describe command('bundle -v') do
  its(:stdout) { should match /Bundler version 2\.3\.14/ }
end
