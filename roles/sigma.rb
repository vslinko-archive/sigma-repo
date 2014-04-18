name 'sigma'

run_list 'recipe[apt]',
         'recipe[ntp]',
         'recipe[vslinko]',
         'recipe[nodejs]',
         'recipe[sigma]'

override_attributes(
  :nodejs => {
    :install_method => 'package'
  }
)
