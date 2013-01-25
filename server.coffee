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
  app.set 'port', 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser
    uploadDir: "#{ __dirname }/tmp"
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

app.post "/upload", ( req, res ) ->
  session = get_session( req )
  if not session?
    for field, file of req.files
      fs.unlink file.path
    res.redirect "/"  
  else
    uploads = [ ]
    for field, file of req.files
      uploads.push
        owner: session.user._id
        path: file.path
        name: file.name
        mime: file.type
        time: file.lastModifiedDate
        hidden: yes
        public: no
        blog_entry: no
        upload: yes
    blog_db.save uploads, ( data, err ) ->
      console.log err if err?
    res.redirect "/user/#{session.user.name}"

app.get '/file/:file', ( req, res ) ->
  session = get_session( req )
  blog_db.get req.param("file")
    , ( err , data ) ->
      console.log data
      if err?
        console.log err
        res.send 404
      else if data.hidden and ( not session or data.owner isnt session.user._id )
        res.send 403      
      else if not session? and not data.public
        res.send 403  
      else
        res.sendfile data.path

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
      console.log( data )
      md5 = crypto.createHash('md5')
      md5.update( req.param("user_data").pass )
      md5.update( data[0].value.salt ) 
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
  if  session?.user?.name is req.param("name")
    res.render "user",
      user: session.user
      notify: undefined
  else
    res.redirect "/"
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
  salt = crypto.randomBytes( 64 ).toString()
  md5.update( salt ) 
  phash = md5.digest 'hex'
  user_db.merge session.user._id , 
    pass: phash
    salt: salt
  , (err, data ) ->
    console.log err if err?
    res.redirect "/"



http.createServer(app).listen app.get('port'), () ->
  console.log "Blog running on #{ app.get('port') }"
