name    'sigma'
version '0.1.0'

%w{ git nginx }.each do |cb|
  depends cb
end
