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

class PathElement
  constructor: ( @parent, data ) ->
    @control = ""
    if data.match /^\d(\.\d*)?,\d(\.\d*)?$/
      c = data.split(",")      
      @handle =  CP( Number(c[0]), Number(c[1])  ) 
      $(@parent.visual).append @handle
      $(@handle).mouseover =>
        $(@handle).attr 
          r: 0.04
        @last =
          x: 0
          y: 0   
        @dragging = off
      $(@handle).mousedown =>
        @last.x = event.clientX
        @last.y = event.clientY
        @dragging = on
      $(@handle).mousemove =>
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

class PathControl
  constructor: ( @element, @scale ) ->
    @visual = G()
    $(@element).parent().append( @visual )
    d = $(@element).attr "d"
    @data = ( new PathElement( @, i ) for i in (d.split(" ")) )
  redraw: ->
    $(@element).attr "d", (element.read() for element in  @data).join(" ")

window.PathControl = PathControl
