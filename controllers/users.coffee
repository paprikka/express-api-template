Users = require '../models/users'
_ = require 'lodash'


index = (req, res, next)->
  vars = 
    title : 'Użytkownicy'

  # res.render '../views/users/index', _.extend vars, {}
  Users.find {}, (err, docs)->
    if req.accepts 'json'
      res.json docs
    else
      res.render '../views/users/index', _.extend vars, users : docs

    if err
      res.json err


getStatus = (req, res, next) -> 
  res.json req.currentUser


newUserForm = (req, res, next)->
  vars =
    title: 'Dodaj użytkownika'
  # req.flash 'error', 'oh noes!'
  res.render '../views/users/new', vars




getSingle = (req, res, next)->
  res.json req.user


update = (req, res, next)->
  console.log 'controllers/users::update'

  query = _id : req.user.id
  specializations = if _.isString req.body.specializations?[0]
    req.body.specializations
  else if _.isObject req.body.specializations?[0]
    _.map(req.body.specializations, (sp)-> sp._id)


  params = 
    email:            req.body.email or no
    fullName:         req.body.fullName or no
    description:      req.body.description or no
    role:             req.body.role or no
    password:         req.body.password or no
    specializations:  specializations or no

  if req.body.mustChangePassword? then params.mustChangePassword = req.body.mustChangePassword

  console.log 'controllers/users::update() request body: ', req.body
  console.log 'controllers/users::update() update params: ', params
  # Tylko, jeśli nowe hasło zostało wprowadzone

  if req.body.password
    console.log 'controllers/users::update() change password: ' + req.body.password

  callback = (err, docs)->
    if err then res.json err
    console.log 'user updated callback'
    console.dir arguments
    res.send docs

  # TODO: refactor! 
  Users.findOne query, (err, doc)->
    if params.email then doc.email = params.email
    if params.fullName then doc.fullName = params.fullName
    if params.description then doc.description = params.description
    if params.role then doc.role = params.role
    if params.password then doc.password = params.password
    if params.mustChangePassword? then doc.mustChangePassword = params.mustChangePassword
    doc.save callback


add     = (req, res, next)->
  b = req.body
  userData = b
  # lepiej to dopisac:)
  user = new Users userData

  user.save (err, docs)->
    if err
      res.json
        message: '_error'
        params : err
    else
      res.json user

bootstrap = (req, res, next)->
  # TODO: disable!
  Users.remove {}
  console.log 'controllers/users:: bootstrap()'
  userData = 
    fullName: "Administrator"
    email: 'admin@admin.com'
    password: 'admin'
    role: 'administrator'

  user = new Users userData

  user.save (err, docs)->
    if err
      res.json
        message: '_error'
        params : err
    else
      res.json user



edit    = (req, res, next)->

remove  = (req, res, next)->
  # res.json req.user
  # return false;
  console.log 'controllers/users::remove()'
  Users.remove {_id: req.user._id}, (err)->
    res.json
      message : 'ok'
  # res.json req.user

UserModel = new Users

loggedIn = (req, res, next)->
  console.log 'loggedIn::session'
  console.dir req.session
  res.redirect '/'


# TODO maybe refactor using promises
login   = (req, res, next)->
  console.log 'controllers/users::login()'

  wrongCredentialsMessage = 
    message: '_error'
    params:
      message: 'invalid password'
      messagePretty: 'Podano niepoprawne dane.'

  # If user ID was found, check credentials
  authenticateFoundUser = (userRes)->
    console.log 'controllers/users::login::auth'
    sess = req.session 

    onUserAuthenticated = ->
      # User ID and password hash match, log in...
      sess.userId = userRes._id
      sess.isAuthorized = yes

      res.send
        message: '_ok' 
        params:
          session: sess
          user: userRes


    # Generate hash to compare
    encrypted = UserModel.encrypt(req.body.password)
    
    if encrypted isnt userRes.password
      # Wrong password
      console.log 'controllers/users::login::auth - wrong password'
      console.log userRes.password + ' vs ' + encrypted
      res.json wrongCredentialsMessage
    else
      # Password ok
      console.log 'controllers/users::login::auth - right password'
      console.log userRes._id
      Users.update(_id: userRes._id, {'$set':{
        token: Date.now
        }}, onUserAuthenticated)


  if req.method.toLowerCase() isnt "post"
    res send "Login"
  else
    console.log 'controllers/users::login - method ok'
    onFind = (err, docs)->
      console.log 'controllers/users::login - search complete'
      if err
        console.log 'controllers/users::login - unknown error'
        console.log err
      if docs is null
        console.log 'controllers/users::login - user id not found'
        res.json wrongCredentialsMessage
      else
        authenticateFoundUser docs
    if req.body.email and req.body.password
      Users.findOne {email: req.body.email}, onFind
    else
      res.json wrongCredentialsMessage


logout  = (req, res, next)-> 
  console.log 'User::logout'
  req.session.userId = null
  res.json
    message: '_ok'




# auth middleware
authenticate = (req, res, next)-> 
  allowedGroups =
    administrator : yes
    manager : yes
  authenticator req, res, next, allowedGroups

authenticateAll = (req, res, next)-> 
  allowedGroups =
    administrator : yes
    manager : yes
    rep: yes
  authenticator req, res, next, allowedGroups

authenticateAdmin = (req, res, next)-> 
  allowedGroups =
    administrator : yes
    manager : no
    rep: no
  authenticator req, res, next, allowedGroups








authenticator = (req, res, next, allowedGroups)->
  console.log 'authenticate------'

  if req.session then console.dir req.session

  if req.session.userId
    Users.find {_id: req.session.userId}, (err, docs)->
      if err
        res.json
          message: '_error'
          params: 'not found'
      else
        loadedUser = docs[0]
        if allowedGroups[loadedUser?.role]
          console.log '\n --- auth: ' + loadedUser.email + ' --- \n'
          req.currentUser = loadedUser
          next()
        else
          console.log 'Users:: insufficient priviledges'
          res.json 403, {'message': '_error', 'params': 'insufficient priviledges'}
  else
    res.json 403, 'message': '_error'

setPassword = (req, res)->
  if req.currentUser.id is req.user.id
    query = _id : req.user.id
    vals  = 
      password: Users::encrypt req.body.password
      mustChangePassword: no
    cb    = (err, docs)->
      if err then throw err
      res.json 
        message: '_ok'
        params:
          user: docs

    Users.update query, vals, cb
  else
    res.json 403, {message: '_error', params: 'access denied'}


setup = (app)->
  app.param 'userId', (req, res, next, userId)->
    Users.findOne({_id: userId})
      .exec (err, user)->
        if err then throw err
        req.user = user
        next()

  app.authenticate = authenticate
  app.authenticateAll = authenticateAll
  app.authenticateAdmin = authenticateAdmin

  app.get '/users/bootstrap', bootstrap

  app.get '/users/new', authenticateAdmin, newUserForm
  app.post '/users/login', login
  app.post '/users/logout', logout
  app.get '/users/logged-in', loggedIn
  app.get '/users/status', authenticate, getStatus
  app.post '/users/set-password/:userId', authenticateAll, setPassword



  app.post '/users/:userId', authenticateAdmin, update
  app.delete '/users/:userId', authenticateAdmin, remove
  app.get '/users/:userId', authenticateAll, getSingle

  
  app.get '/users', authenticate, index
  app.post '/users', authenticateAdmin, add

  _public = 
    authenticate : authenticate  
module.exports = setup
