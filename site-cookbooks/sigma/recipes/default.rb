require 'json'

include_recipe 'git'
include_recipe 'nginx'

sigma_config = data_bag_item('sigma', 'sigma')

directory '/var/www' do
  owner 'www-data'
  group 'www-data'
  mode 0770
end

directory '/var/www/.ssh' do
  owner 'www-data'
  group 'www-data'
  mode 0700
end

file '/var/www/.ssh/id_rsa' do
  content sigma_config['deploy_key']
  owner 'www-data'
  group 'www-data'
  mode 0400
end

git '/var/www/sigma' do
  repository 'git@github.com:rithis/sigma.git'
  user 'www-data'
  group 'www-data'
  notifies :restart, 'service[sigma-backend]'
  notifies :restart, 'service[sigma-sender]'
  notifies :restart, 'service[sigma-receiver]'
end

execute 'npm install' do
  cwd '/var/www/sigma'
  environment 'HOME' => '/var/www'
  user 'www-data'
  group 'www-data'
end

execute '/var/www/sigma/node_modules/gulp/bin/gulp.js build' do
  cwd '/var/www/sigma'
  environment 'HOME' => '/var/www'
  user 'www-data'
  group 'www-data'
end

file '/var/www/sigma/build/production.json' do
  content JSON.pretty_generate(sigma_config['sigma_config'])
  owner 'www-data'
  group 'www-data'
  notifies :restart, 'service[sigma-backend]'
  notifies :restart, 'service[sigma-sender]'
  notifies :restart, 'service[sigma-receiver]'
end

sigma_services = [
  {:name => 'backend', :script => 'index.js'},
  {:name => 'sender', :script => 'mailer.js'},
  {:name => 'receiver', :script => 'receiver.js'}
]

sigma_services.each do |sigma_service|
  template "/etc/init/sigma-#{sigma_service[:name]}.conf" do
    source 'upstream.conf.erb'
    variables :service => sigma_service
  end

  link "/etc/init.d/sigma-#{sigma_service[:name]}" do
    to '/lib/init/upstart-job'
  end

  service "sigma-#{sigma_service[:name]}" do
    action [:enable, :start]
  end
end
