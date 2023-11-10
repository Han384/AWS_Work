require 'spec_helper'

#Gitがインストールされているか
describe package('git') do
  it { should be_installed }
end

