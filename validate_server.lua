local url = require "net.url"

function validate_server(hs_url)
  u = url.parse(hs_url):normalize()

  if not (u.host and u.scheme) then
    return error("'"..hs_url.."' doesn't look like a valid url. Please specify scheme (http/s) and hostname")
  end

  if u.port and u.port == 8448 and u.scheme == 'http' then
    return error("Port 8448 is for https, make sure your homeserver URL is correct")
  end

  if u.port and u.port == 8008 and u.scheme == 'https' then
    minetest.log("warn", "Port 8008 is not https, make sure your homeserver URL is correct")
  end

  return hs_url
end


