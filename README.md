
# Matrix mod for Minetest


This mod creates a bridge between a [Matrix](https://matrix.org) channel and the in-game chat.  
The code is shamelessly based on the [irc](https://github.com/minetest-mods/irc) mod and examples from [lua-matrix](https://github.com/aperezdc/lua-matrix).


## Installing

```bash
cd <Mods directory> && git clone --recursive git@github.com:diggers-mt/minetest-matrix.git
```

### OS X

```bash
brew install lua@5.1
luarocks-5.1 install lua-cjson
brew install openssl
luarocks-5.1 install cqueues CRYPTO_DIR=/usr/local/opt/openssl/ OPENSSL_DIR=/usr/local/opt/openssl #https://github.com/wahern/cqueues/wiki/Installation-on-OSX#via-brew
luarocks-5.1 install luaossl CRYPTO_DIR=/usr/local/opt/openssl/ OPENSSL_DIR=/usr/local/opt/openssl
export MATRIX_API_HTTP_CLIENT=luasocket
```

### Ubuntu

Tested on 16.04.

```bash
apt-get install lua5.1 luarocks lua-sec
luarocks install lua-cjson
export MATRIX_API_HTTP_CLIENT=luasocket
```

You might need to prepend `sudo` to first and second commands.

You also need to add Matrix to your trusted mods if you haven't disabled mod security.

```
secure.trusted_mods = matrix
```

[wiki]: https://wiki.minetest.net/Installing_mods


## Settings

* `matrix.user`: Matrix username, for example `@minetestbot:matrix.org`

* `matrix.password`: Password for Matrix user

* `matrix.server`: Server to connect to, include http(s), `https://matrix.org`

* `matrix.port`: Server port, default `8448`

* `matrix.room_id`: Room to join, `room_id` in matrix. Always starts with `!`


## License

See `LICENSE.txt` for details.
