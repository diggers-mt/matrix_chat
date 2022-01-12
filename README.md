
# Matrix mod for Minetest


This mod creates a bridge between a [Matrix](https://matrix.org) channel and the in-game chat.
The code is shamelessly based on the [irc](https://github.com/minetest-mods/irc) mod and examples from [lua-matrix](https://github.com/aperezdc/lua-matrix).

This branch (`master`) needs a Matrix user that listens for messages and sends to Minetest. Chat messages posted in-game
will be sent with the bot to the Matrix channel like so:

```
@minetestbot: <myuser> hello world
```

For a bridge where virtual users are created in Matrix, checkout the [appservice](https://github.com/diggers-mt/minetest-matrix/tree/appservice) branch!

**This is a work in progress**
Until we have a stable release, expect breaking changes and whatnot.

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
luarocks-5.1 install luasocket
luarocks-5.1 install luasec OPENSSL_DIR=/usr/local/opt/openssl
export MATRIX_API_HTTP_CLIENT=luasocket
```

### Ubuntu

Tested on 16.04.

```bash
apt-get install lua5.1 luarocks lua-sec
luarocks install lua-cjson
luarocks install luasocket
luarocks install luasec
export MATRIX_API_HTTP_CLIENT=luasocket
```

You might need to prepend `sudo` to first and second commands.

For the moment you need to add `matrix_chat` to `secure.trusted_mods` for lua-matrix to work. This will hopefully change.

```
secure.trusted_mods = matrix_chat
```

[wiki]: https://wiki.minetest.net/Installing_mods


## Settings

* `matrix.user`: Matrix username, for example `@minetestbot:matrix.org`

* `matrix.password`: Password for Matrix user

* `matrix.server`: Server to connect to, include http(s) and port, `https://matrix.org`

* `matrix.room_id`: Room to join, `room_id` in matrix. Always starts with `!`

### Removed, don't use
* `matrix.port`: Server port, default `8448`


## License

See `LICENSE.txt` for details.
