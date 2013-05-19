http = require 'http'
https = require 'https'

url = require 'url'

getJSON = require('../lib/get-json').getJSON


setup = (app)->
  app.param 'target', (req, res, next, target)->
    req.target = target
    next()

  app.get '/proxy/*', (req, res, next)->
    targetUrl = req.url.slice 7
    urlOptions = url.parse targetUrl
    getJSON urlOptions, (statusCode, result)->
      res.json result 

module.exports = setup


# var options = {
#     host: 'somesite.com',
#     port: 443,
#     path: '/some/path',
#     method: 'GET',
#     headers: {
#         'Content-Type': 'application/json'
#     }
# };