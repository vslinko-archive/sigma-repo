require 'highline/import'
require 'net/http'
require 'fileutils'
require 'json'

task :default => [
  :generate_deploy_key,
  :post_deploy_key,
  :update_sigma_config
]

task :generate_deploy_key do
  system 'ssh-keygen -N "" -C "" -f .chef/deploy_key'
end

task :post_deploy_key do
  username = ask("Enter Github username: ") { |q| q.echo = true }
  password = ask("Enter Github password: ") { |q| q.echo = false }

  uri = URI('https://api.github.com/repos/rithis/sigma/keys')

  req = Net::HTTP::Post.new(uri)
  req.basic_auth username, password
  req.body = JSON.generate({
    :title => 'Generated deploy key',
    :key => File.read('.chef/deploy_key.pub')
  })
  req.content_type = 'application/json'

  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http| http.request(req) }

  puts res.body
end

task :update_sigma_config do
  if File.exists? 'data_bags/sigma/sigma.json'
    sigma_config = JSON.parse(File.read('data_bags/sigma/sigma.json'))["sigma_config"]
  else
    sigma_config = {}
  end

  tmp_file = `mktemp -t sigma`.strip!
  File.write(tmp_file, JSON.pretty_generate(sigma_config))
  editor = ENV.fetch("EDITOR", "vim")
  system "#{editor} #{tmp_file}"
  sigma_config = JSON.parse(File.read(tmp_file))
  File.delete tmp_file

  data_bag = {
    :id => "sigma",
    :deploy_key => File.read('.chef/deploy_key'),
    :sigma_config => sigma_config
  }

  FileUtils.mkdir_p 'data_bags/sigma'
  File.write 'data_bags/sigma/sigma.json', JSON.generate(data_bag)
end
