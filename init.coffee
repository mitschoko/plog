fs = require("fs")
crypto = require("crypto")
init_config = require( "./init_config.json" )

needed = [ 
  "my_name"
  "init_pass"
  "url"
  "port"
  "couch_host"
  "couch_port"
  "couch_user"
  "couch_pass"
]


config = {}
config_good = yes

for requirement in needed
  if not init_config[requirement]?
    console.log( "Field #{ requirement } is missing in init_config.json!" )
    config_good = no
  else
    config[ requirement ] = init_config[requirement]

if not config_good
  console.log "Please add missing fields and try again!"
  process.exit( 1 )


config.secret_token = crypto.randomBytes( 256 ).toString()

console.log "Writing config.json..."
fs.writeFileSync( "config.json", JSON.stringify( config ) )
console.log "done."



cradle = require("cradle")


con = new cradle.Connection  "http://#{config.couch_host}", config.couch_port,
  cache: false
  raw: false
  auth:
    username: config.couch_user
    password: config.couch_pass


db_blog_name = "blog_#{ config.my_name }"
console.log "Creating database #{ db_blog_name } ..."
db_blog = con.database db_blog_name

db_blog.create ( err, res ) ->
  console.log err if err?
  db_blog.save "_design/blog", 
    views:
      byTime:
        map: """(
        function ( doc ) { 
          if (doc.block_entry && doc.time) { 
            d = new Date( doc.time );  
            emit( d.valueOf(),  doc ); 
          } 
        }
        )""" 
      uploads:
        map: """(
        function ( doc ) {
          if (doc.upload && doc.upload === true ){
            emit( doc._id, doc );
          }
        }
        )""" 
console.log "done."

db_users_name = "blog_#{config.my_name}_users"
console.log "Creating database #{ db_users_name } ..."

db_users = con.database db_users_name
db_users.create (err, res ) ->
   console.log err if err?
   db_users.save "_design/user", 
      human: 
        map: """(
          function( doc ) {
            if ( doc.human ) {
               emit( doc._id , doc);
            }
          }  
        )"""
      byName: 
        map: """(
          function( doc ) {
            if ( doc.valid_user ) {
               emit( doc.name , doc );
            }
          }  
        )"""
      byConntactKey:
        map: """(
          function( doc ) {
            if ( (! doc.vaild_user ) && doc.conntact_key ) {
               emit( doc.welcome_key, doc )
            }
          }
          )"""
    , ( err, res ) ->
      console.log err if err?
      console.log "done."
      console.log "creating user #{ config.my_name }"
      md5 = crypto.createHash('md5')
      md5.update( config.init_pass )
      salt = crypto.randomBytes( 64 ).toString()
      md5.update( salt )
      phash = md5.digest 'hex'
      db_users.save 
        name: config.my_name 
        valid_user: yes
        pass: phash
        salt: salt
        change_pass: yes 
        is_author: yes
        is_admin: yes
        human: yes
      , ( err, res ) ->
        console.log err if err?
        console.log "done."
