class Rack::Attack
  blocklist('block common WordPress scans') do |req|
    req.path.match?(%r{/(wp-admin|wp-login|wordpress|cms/wp-includes|wlwmanifest\.xml)})
  end
end
