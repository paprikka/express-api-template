index = (req, res)->
  console.log 'index page:: session:'
  console.dir req.session
  console.log 'index page, ie. app loaded'
  res.render 'pages/index'

setup = (app)->
  app.get '/', index

module.exports = setup