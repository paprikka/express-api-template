express     = require 'express'
http        = require 'http'
path        = require 'path'
MongoStore  = require('connect-mongo') express
RedisStore  = require('connect-redis') express
mongoose    = require 'mongoose'



exports.set = (app)->
  app.configure ->
    app.set 'port', process.env.PORT or 8088
    app.set 'views', __dirname + '/views'
    app.set 'view engine', 'jade'
    # app.set 'view cache', off


    # app.use express.favicon()
    # app.use express.logger('dev')
 

    app.use express.bodyParser uploadDir : './tmp'
    app.use express.methodOverride()
    app.use express.cookieParser()

    app.use express.session
      secret: 'your special secret message!'
      store:  new RedisStore
      maxAge: new Date(Date.now() + 3600000)




    app.use app.router
    app.use express.static path.join(__dirname, 'public')


  app.configure 'development', -> 
    app.use express.errorHandler()

  mongoose.connect 'mongodb://localhost/express-api-example'
