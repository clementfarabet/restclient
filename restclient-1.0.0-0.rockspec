package = "restclient"
version = "1.0.0-0"

source = {
   url = "git://github.com/clementfarabet/restclient",
   tag = "1.0.0-0",
}

description = {
   summary = "A REST Client.",
   detailed = [[
A client to REST APIs.
   ]],
   homepage = "https://github.com/clementfarabet/restclient",
   license = "BSD"
}

dependencies = {
   "luasocket >= 2.0.2",
   "lua-cjson >= 2.1.0",
   "graphicsmagick >= 1.0.0",
}

build = {
   type = "builtin",
   modules = {
      ['restclient.init'] = 'init.lua',
   }
}