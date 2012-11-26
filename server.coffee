express = require('express')
routes = require('./routes')
crypto = require('crypto')
http = require('http')
config = require('./config.json')
cradle = require('cradle')
console.log "setting up connection @ #{config.couch_host}:#{config.couch_port}"
con = new cradle.Connection  "http://#{config.couch_host}", config.couch_port,
  cache: true
  raw: false
  auth:
    username: config.couch_user
    password: config.couch_pass
console.log "Done"
blog_db_name = "blog_#{ config.my_name }"
console.log "Connecting to Blog Database #{ blog_db_name }"
blog_db = con.database blog_db_name
console.log "Done"


user_db_name = "blog_#{ config.my_name }_users"
console.log "Connecting to Blog Database #{ user_db_name }"
user_db = con.database user_db_name
console.log "Done"

app = express()

app.configure () ->
  app.set 'port', config.port | 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.cookieParser config.secret_token
  app.use express.session()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static "#{ __dirname }/public"
  

app.configure 'development', () ->
  app.use express.errorHandler()


current_sessions = {}

get_session = (req) ->
   if req.signedCookies["connect.sid"]?
     current_sessions[req.signedCookies["connect.sid"]]?.last_active = new Date()
     current_sessions[req.signedCookies["connect.sid"]]
   else
     undefined

app.get '/', (req, res) ->
  session = get_session( req )
  user = if session?.user? then session.user else undefined
  blog_db.view 'blog/byTime',
    limit: 3
    descending: true  
    ,( err, data ) ->
      console.log err if err?
      res.render 'main',
        title: config.name
        posts: data
        user: user
        notify: undefined

app.post '/post', ( req, res ) ->
  session = get_session( req )
  res.redirect '/' if not session?.user?.is_author
  entry = 
    text: req.param("blog_post").text 
    time: Date()
    block_entry: yes
  blog_db.save entry, ( err, data ) ->
    if err?
      console.log err
    res.redirect '/'  if data.ok


app.post '/login', (req, res) ->
  res.redirect '/' if  not req.param("user_data")?.name? or not req.param("user_data")?.pass? 
  user_db.view 'user/byName',
    key: req.param("user_data").name
  , ( err, data ) ->
    if err? or data.length isnt 1
      res.redirect '/' 
    else
      md5 = crypto.createHash('md5')
      md5.update( req.param("user_data").pass )
      md5.update( config.salt ) 
      phash = md5.digest 'hex'
      if data[0].value.pass is phash
        current_sessions[ req.signedCookies["connect.sid"] ] =
          user: data[0].value
          last_active: new Date()
        res.redirect "/"
      else
        res.redirect "/"

app.get '/logout', (req, res ) ->
   if req.signedCookies["connect.sid"]?
     delete current_sessions[req.signedCookies["connect.sid"]]
   res.redirect "/"

app.get '/user/:name', (req, res) ->
  session = get_session( req ) 
  if not session?.user?.name? == req.param("name")
    res.status 403 
  else
    res.render "user",
      user: session.user
###
# TODO implement
app.get '/users', (req, res) ->
  session = get_session( req )
  res.redirect "/" if not session?.user?.is_admin
###
        
app.post '/resetpass', (req, res) ->
  session = get_session( req )
  res.redirect '/' if not session
  res.redirect '/' if  not req.param("user_data")?.pass1? or not req.param("user_data")?.pass2? or not req.param("user_data").pass1 is req.param("user_data").pass2 
  md5 = crypto.createHash('md5')
  md5.update( req.param("user_data").pass1 )
  md5.update( config.salt ) 
  phash = md5.digest 'hex'
  user_db.merge session.user._id , pass: phash, (err, data ) ->
     console.log err if err?
     res.redirect "/"



http.createServer(app).listen app.get('port'), () ->
  console.log "Blog running on #{ app.get('port') }"
