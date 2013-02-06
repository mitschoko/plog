fefe = require("./fefe.coffee")

fefe = fefe.fefe

ipsum =  """
Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit amet, consectetur, adipiscing velit, sed quia non numquam do eius modi tempora incididunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur?
 At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat...
"""
words = /(\w+)/g
inner_words = /([a-z]+\,?)/g
first_words = /([A-Z]{1}[a-z]*)/g
last_words = /(\w+)(?=\.)/g




class Chooser
  constructor: ( data ) ->
    @accData = []
    acc = 0
    for key, val of data
      acc += val
      @accData.push
        w: key
        p: acc
  getWord: ->
    p = Math.random()
    half = ( pos, range ) =>
      if (  @accData[pos]?.p or 0  ) <= p <= (@accData[ pos + 1 ]?.p or 1)
        return @accData[ pos ]?.w or ""
      else
        range = Math.floor( range / 2 ) or 1 
        if @accData[pos].p < p 
          pos += range  
        else
          pos -= range
        half pos,range
    half( Math.floor( @accData.length / 2) , Math.floor( @accData.length / 2 ) ) 


class WordEntropy
  constructor: ( data ) ->
    first = data.match first_words
    @first = {}
    console.log first
    p = 1.0 / first.length
    for word in first
      @first[word] = ( @first[word] or 0 ) +  p
    inner = data.match inner_words
    console.log inner
    @inner = {}
    p = 1.0 / inner.length
    for word in inner
      @inner[word] = ( @inner[word] or 0 ) +  p
    last  = data.match last_words
    console.log last
    @last = {}
    p = 1.0 / last.length
    for word in last
      @last[word] = ( @last[word] or 0 ) +  p
    @firstChooser = undefined
    @innerChooser = undefined
    @lastChooser  = undefined
  getSentence:  ->
    if not @firstChooser? or not @innerChooser? or not @lastChooser?
      @firstChooser = new Chooser( @first )
      @innerChooser = new Chooser( @inner )
      @lastChooser = new Chooser( @last )
    text = "#{@firstChooser.getWord()}" 
    text += " #{(@innerChooser.getWord() for i in [0..(Math.random() * 10 + 5)]).join(" ")}"
    text += " #{@lastChooser.getWord()}."    
  getSentences: ( n ) ->
    (@getSentence() for i in [0..n]).join(" ")


IpsumGen = new WordEntropy( fefe )




sec = 1000 
intervals = [ 
  (hmin = 30 * sec ),
  (min = 60 * sec ),
  (hour = 60 * min ),
  (day  = 24 * hour),
  (week = 7 * day )
]

randomTimeStep = ->
  (Math.random() * 10) * intervals[ Math.floor( Math.random() * intervals.length)]


r = ( x ) ->
  ( x * 2  * Math.random() ) - x

vr = (x ) ->
  x + r(0.05)

smile = ->
  "M #{vr( 0.1 )},#{vr( 0.6 )}  C #{vr(0.33333333)},#{vr(0.9)} #{vr(0.66666666)},#{vr(0.9)} #{vr(0.9)},#{vr(0.6)} L #{vr(0.9)},#{vr(0.6)} C #{vr(0.66666666)},#{vr(0.6)} #{vr(0.33333333)},#{vr(0.6)} #{vr(0.1)},#{vr(0.6)} z"


colors = [
  "#000000",
  "#0000FF",
  "#00FF00",
  "#00FFFF",
  "#FF0000",
  "#FF00FF",
  "#FFFF00",
  "#FFFFFF"
]
rcol = ->
  colors[ Math.floor( Math.random() * colors.length ) ]



config = require("./config.json")
cradle = require("cradle")

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

i = 0
nowT = new Date().valueOf()
T = nowT
while i < 530
  rstep = randomTimeStep()
  T -= rstep
  post = 
    block_entry: true
    time: new Date( T ) 
    smile:
      leftEye:
        x: vr(0.333)
        y: vr(0.333)
        fill: rcol()
      rightEye:
        x: vr(0.666)
        y: vr(0.333)
        fill: rcol()
      mouth:
        outline: smile()
  if 1 <= 3 * Math.random()
    post.smile.text = IpsumGen.getSentences( 1 + Math.floor( Math.random() * 12 )  )
  blog_db.save( post )
  ++i




