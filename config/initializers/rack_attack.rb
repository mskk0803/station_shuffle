class Rack::Attack
  blocklist('block common WordPress scans') do |req|
    req.path.start_with?('/wordpress', '/wp-admin', '/wp-login.php')
  end
end
