require 'spec_helper'

#テストするポートの定義
listen_port = 80

#Nginxがインストール済か
describe package('nginx') do
  it { should be_installed }
end

#指定のポートがリッスン（通信待ち受け状態）か
describe port(listen_port) do
  it { should be_listening }
end

#テスト接続して動作しているか
describe command('curl http://127.0.0.1:#{listen_port}/_plugin/head/ -o /dev/null -w "%{http_code}\n" -s') do
  its(:stdout) { should match /^200$/ }
end

#Rubyが指定のバージョンか
describe command('ruby -v') do
  its(:stdout) { should match /ruby 3\.1\.2/ }
end

#Bundlerが指定のバージョンか
describe command('bundle -v') do
  its(:stdout) { should match /Bundler version 2\.3\.14/ }
end

#Railsが指定のバージョンか
describe command('rails -v') do
  its(:stdout) { should match /Rails 7\.0\.4/ }
end

#Nodeが指定のバージョンか
describe command('node -v') do
  its(:stdout) { should match /v17\.9\.1/ }
end

#Yarnが指定のバージョンか
describe command('yarn -v') do
  its(:stdout) { should match /1\.22\.19/ }
end
