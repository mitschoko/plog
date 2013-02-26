G =  ->
  document.createElementNS("http://www.w3.org/2000/svg", "g")

CP = (  x, y ) ->
  obj = document.createElementNS("http://www.w3.org/2000/svg", "circle");
  obj.setAttributeNS(null, "cx", x)
  obj.setAttributeNS(null, "cy", y)
  obj.setAttributeNS(null, "r",  0.02)
  obj.setAttributeNS(null, "stroke", "white")
  obj.setAttributeNS(null, "stroke-width", 0.01)
  obj.setAttributeNS(null, "fill", "red")
  obj


Polygon = (  stroke, swidth, fill ) ->
  obj = document.createElementNS("http://www.w3.org/2000/svg", "polygon");
  obj.setAttributeNS(null, "stroke", stroke)
  obj.setAttributeNS(null, "stroke-width", swidth)
  obj.setAttributeNS(null, "fill", fill)
  obj.setAttributeNS(null, "points", " ")
  obj



class PathElement
  constructor: ( @parent, data ) ->
    @control = ""
    if data.match /^\d(\.\d*)?,\d(\.\d*)?$/
      c = data.split(",")      
      @handle =  CP( Number(c[0]), Number(c[1])  ) 
      $(@parent.visual).append @handle
      $(@handle).mouseover =>
        event.preventDefault()
        $(@handle).attr 
          r: 0.04
        @last =
          x: 0
          y: 0   
        @dragging = off
      $(@handle).mousedown =>
        event.preventDefault()
        @last.x = event.clientX
        @last.y = event.clientY
        @dragging = on
      $(@handle).mousemove =>
        event.preventDefault()
        if @dragging
          now = 
            x: event.clientX
            y: event.clientY
          $(@handle).attr
            cx: Number($(@handle).attr('cx')) + (now.x - @last.x) / @parent.scale
            cy: Number($(@handle).attr('cy')) + (now.y - @last.y) / @parent.scale
          @last = now
          @parent.redraw()
      $(@handle).bind "mouseup mouseout", =>
        $(@handle).attr "r", 0.02
        @dragging  = off
    else
      @control = data
  read: ->
      if @handle
        "#{$(@handle).attr('cx')},#{$(@handle).attr('cy')}"
      else
        @control
  translate: ( dx, dy ) ->
   $(@handle).attr
     cx: Number($(@handle).attr('cx')) + dx / @parent.scale
     cy: Number($(@handle).attr('cy')) + dy / @parent.scale

class PathControl
  constructor: ( @element, @scale ) ->
    @visual = G()
    $(@element).parent().append( @visual )
    d = $(@element).attr "d"
    @data = ( new PathElement( @, i ) for i in (d.split(" ")) )
  redraw: ->
    $(@element).attr "d", (element.read() for element in  @data).join(" ")

class PolygonDraw
  constructor: (  @visual, @scale ) ->
    @element = Polygon("#000000", 3 /  @scale,  "#FFFFFF" )
    @last = 
      x: 0
      y: 0
    $(@visual).append( @element )
    @points = []
    @dragging = off
    $(@element).mousedown (evt) =>
      evt.preventDefault()
      @last.x = evt.clientX
      @last.y = evt.clientY
      @dragging = on
    $(@element).mousemove (evt) =>
      evt.preventDefault()
      if @dragging 
        @translate( evt.clientX - @last.x,  evt.clientY  - @last.y)
        @last.x = evt.clientX
        @last.y = evt.clientY
    $(@element).mouseup (evt) =>
      evt.preventDefault()
      @dragging = off
  redraw: ->
    $(@element).attr "points", (element.read() for element in  @points).join(" ")
  add: (x, y) -> 
    @points.push new PathElement( @, "#{ x / @scale },#{ y / @scale }" )
    @redraw()
  translate: ( dx, dy ) ->
    for point in @points
      point.translate( dx, dy )
    @redraw()
  showEdit: ->
    for point in @points
      $(point.handle).show()
  hideEdit: ->
    for point in @points
      $(point.handle).hide()

window.PathControl = PathControl
window.PolygonDraw = PolygonDraw
