
express   = require 'express'
http      = require 'http'
path      = require 'path'
config    = require './config'





app = express()


# Apply config:
# ---------------------------------
config.set app

# Init controllers:
# ---------------------------------
(require("./controllers/#{name}")(app) for name in [
  "users" # TODO: add authentication layer
  "proxy"
  "pages"
])

http.createServer(app)
  .listen app.get('port'), ->
    console.log '(COFFEE) Express server listening on port '  + app.get 'port'

