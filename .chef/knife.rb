chef_server_url 'https://chef.vslinko.com'

node_name 'admin'
client_key 'admin.pem'
validation_key '.chef/validation.pem'

cookbook_path ['cookbooks']

syntax_check_cache_path '.chef/cache'
