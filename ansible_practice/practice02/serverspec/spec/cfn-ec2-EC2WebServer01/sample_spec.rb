require 'spec_helper'

############################################
# 配列・変数の設定
############################################

# 配列・変数の設定：以降のテストコードで使用
packages = ['git',
            'make',
            'gcc-c++',
            'patch',
            'openssl-devel',
            'libffi-devel',
            'libicu-devel',
            'libxml2',
            'libxslt',
            'libxml2-devel',
            'libxslt-devel',
            'zlib-devel',
            'readline-devel',
            'ImageMagick',
            'ImageMagick-devel',
            'nginx',
            'mysql-community-devel',
            'mysql-community-server'
            ]
app_dir = "/home/ec2-user/raisetech-live8-sample-app"
nginx_conf_file = "/etc/nginx/conf.d/raisetech-live8-sample-app.conf"
services = ['nginx', 'mysqld']
listen_port_puma = 3000
listen_port_nginx_unicorn = 80

# 環境変数の値を変数に設定：以降のテストコードで使用
aws_alb_endpoint = ENV['AWS_ALB_ENDPOINT']
#aws_alb_endpoint = ENV['ALB_DNS']
aws_s3_bucket = ENV['AWS_S3_BUCKET']


############################################
# テストコード
############################################

# 各種packageがインストールされているか (上記配列に記載されているもの)
packages.each do |package|
    describe package(package) do
        it { should be_installed }
    end
end

# Rubyが指定のバージョンか
describe command('ruby -v') do
  let(:path) { '/home/ec2-user/.rbenv/shims:$PATH' }
  its(:stdout) { should match /ruby 3.1.2/ }
end

# Bundlerが指定のバージョンか
describe package('bundler') do
  let(:path) { '/home/ec2-user/.rbenv/shims:$PATH' }
  it { should be_installed.by('gem').with_version('2.3.14') }
end

# Railsが指定のバージョンか
describe package('rails') do
  let(:path) { '/home/ec2-user/.rbenv/shims:$PATH' }
  it { should be_installed.by('gem').with_version('7.0.4') }
end

# Nodeが指定のバージョンか
describe command('node -v') do
  let(:path) { '/home/ec2-user/.rbenv/shims:$PATH' }
  its(:stdout) { should match /v17\.9\.1/ }
end

# Yarnが指定のバージョンか
describe command('yarn -v') do
  let(:path) { '/home/ec2-user/.rbenv/shims:$PATH' }
  its(:stdout) { should match /1\.22\.19/ }
end

# アプリケーションのディレクトリが指定した場所にあるか (指定されたディレクトリが存在し、ディレクトリであるか)
describe file(app_dir) do
    it { should be_directory }
end

# # Nginxがインストールされているか
# describe package('nginx') do
#   it { should be_installed }
# end

# Nginxの設定ファイルがあるか (指定されたパスのファイルが存在し、ファイルであるか)
describe file(nginx_conf_file) do
  it { should be_file }
end

# # Nginxが起動しているか
# describe service('nginx') do
#   it { should be_running }
# end

# serviceという配列に記述されているサービスが起動(実行)されているか：nginx・mysqld
services.each do |service|
    describe service(service) do
        it { should be_running }
    end
end

# UnicornがGemとしてインストールされているか
describe package('unicorn') do
  let(:path) { '/home/ec2-user/.rbenv/shims:$PATH' }
  it { should be_installed.by('gem') }
end

# Unicornが起動しているか (psコマンドを使ってUnicornのプロセスが実行されているか)
# unicorn master
describe command('ps aux | grep unicorn') do
  its(:stdout) { should match /unicorn_rails master/ }
end

# unicorn worker
describe command('ps aux | grep unicorn') do
  its(:stdout) { should match /unicorn_rails worker/ }
end

# # 指定のポートがリッスン（通信待ち受け状態）か
# describe port(listen_port_puma) do
#     it { should be_listening }
# end

# 指定のポートがリッスン（通信待ち受け状態）か
describe port(listen_port_nginx_unicorn) do
  it { should be_listening }
end

# リモートホスト上でcurlを使用し、指定されたポートに対してHTTPリクエストを送信してHTTPステータスコードが200であるか
describe command('curl http://127.0.0.1:#{listen_port_nginx_unicorn}/ -o /dev/null -w "%{http_code}\n" -s') do
  its(:stdout) { should match /^200$/ }
end

# リモートホスト上でcurlを使用し、指定されたALBエンドポイントに対してHTTPリクエストを送信し、HTTPステータスコードが200であるか
# describe command("curl http://#{aws_alb_endpoint}/ -o /dev/null -w '%{http_code}\n' -s") do
describe command("curl http://#{aws_alb_endpoint}/ -o /dev/null -w '%{http_code}\n' -s") do
  its(:stdout) { should match /^200$/ }
end

# # S3接続確認：接続先で認証情報・profile設定がないため aws cli の実行不可となり、テスト実行失敗となる
# describe command("aws s3 ls s3://#{aws_s3_bucket}") do
#   its(:exit_status) { should eq 0 }
# end
