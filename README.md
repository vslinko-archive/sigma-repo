```
bundle install
berks install -p cookbooks
knife cookbook upload --all
knife role from file roles/*
knife data bag create sigma
knife data bag from file sigma data_bags/sigma/sigma.json
knife bootstrap 83.229.185.17 -N sigma.pegas.vslinko.com -r 'role[sigma]' -x vyacheslav --sudo
```
