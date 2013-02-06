$(document).ready ->
  ### 
  test_intersect = (  a, b )
    z = a.x * b.y - a.y * b.x
    return undefined if z < 0.0001
    c = 
      x: (a.y - b.y) / z
      y: (a.x - b.x) / z
    xr = if a.x < b.x then [a.x, b.x] else [b.x, a.x]
    yr = if a.y < b.y then [a.y, b.y] else [b.y, a.y]
    if (xr[0] <= c.x <= xr[1]) and (yr[0] <= c.y <= yr[1])
      c
    else
      undefined

  hairpath = []
  hairpart = undefiend
  $("#SmileyEditor").mousedown ->
    if $("#drawHair:checked").length isnt 0
      new_c:
        x: event.clientX
        y: event.clientY
      for i, old_c of hairpath
        if 
  ###       
  
  $("#changeEyeColor").change -> $(".eye .center .iris").attr "fill", $("#changeEyeColor").val() 
  $("#toggleControlPoints").click -> $(".control").toggle()


  lastX = undefined
  lastY = undefined
  dragging = undefined

  $(".pupil").each (idx, el ) ->
    $( el ).css "pointer-events", "none"

  moveEye = ( side, x, y ) ->
    center_x = Number($(".eye.#{side} .center .iris").attr( "cx" ))
    center_y = Number($(".eye.#{side} .center .iris").attr( "cy" ))
    eye_x = Number($(".eye.#{side} .ball").attr( "cx" ))
    eye_y = Number($(".eye.#{side} .ball").attr( "cy" ))
    dist =  Math.sqrt( Math.pow( center_x - eye_x + x , 2 ) + Math.pow( center_y - eye_y + y, 2 ) )
    max_dist =  Math.abs( Number($(".eye.#{side} .ball").attr( "r" )) - Number($(".eye.#{side} .center .iris").attr("r") ))
    if dist <= max_dist
      $(".eye.#{side} .center *").each (idx, el) -> 
        $(el).attr 
          cx: center_x + x 
          cy: center_y + y 
  movingEye = false
  $(".eye.right .center .iris").mousedown ->
    if not dragging? or movingEye
      console.log "get down"
      lastX = event.clientX
      lastY = event.clientY 
      movingEye = true

  $(".eye.left .center .iris").mousedown ->
    if not dragging? or movingEye
      console.log "get down"
      lastX = event.clientX
      lastY = event.clientY  
      movingEye = true

  $(".eye.left  .center .iris").mousemove ->
    if movingEye
      if $("#editLeftEyePosition:checked").length isnt 0
        console.log "moving"
        dx = event.clientX - lastX
        dy = event.clientY - lastY
        moveEye "left", dx, dy 
        moveEye "right", dx, dy if $("#editRightEyePosition:checked").length isnt 0
      lastX = event.clientX
      lastY = event.clientY
     
  $(".eye.right .center .iris").mousemove ->
    if movingEye
      if $("#editRightEyePosition:checked").length isnt 0
        console.log "moving"
        dx = event.clientX - lastX
        dy = event.clientY - lastY
        moveEye "right", dx, dy 
        moveEye "left", dx, dy if $("#editLeftEyePosition:checked").length isnt 0
      lastX = event.clientX
      lastY = event.clientY

  $(".eye .center .iris").mouseout -> 
    console.log "release"
    movingEye = false 
  $(".eye .center .iris").mouseup  ->
    console.log "release"
    movingEye = false

  getCP = ( query ) ->
    "#{$(query).attr("cx")},#{$(query).attr("cy")}"
  CPcontext = ( context ) ->
    ( query ) ->
      getCP("#{context}#{query}")
  mouth = CPcontext("circle.control.mouth")
  redrawSmile = ->
    $("#mouth .outline").attr
      d: "M #{ (start = mouth('.right.end')) } C #{ mouth('.right.down.ctr')} #{ mouth('.left.down.ctr') } #{ mouth('.left.end') } #{ mouth('.left.up.ctr') } #{ mouth('.right.up.ctr') } #{start}  z"

  $(".control").mouseover (evt) ->
    evt.preventDefault()
    $(@).attr 
      r: 16

  $(".control").bind "mousedown touchstart", (evt) ->
     evt.preventDefault()
     if evt.originalEvent.touches?.length > 0 
       lastX = evt.originalEvents.touches[0].clientX
       lastY = evt.originalEvents.touches[0].clientY
     else
       lastX = evt.clientX
       lastY = evt.clientY
     if not dragging?
       dragging =  @ 
  $(".control").bind "mousemove touchmove", (evt) ->
     evt.preventDefault()
     if evt.originalEvent.touches?.length > 0 
       nowX = evt.originalEvents.touches[0].clientX
       nowY = evt.originalEvents.touches[0].clientY
     else
       nowX = evt.clientX
       nowY = evt.clientY
     if @ is dragging
       $(@).attr
          cx: Number($(@).attr('cx')) + (nowX - lastX)
          cy: Number($(@).attr('cy')) + (nowY - lastY)
       redrawSmile()
     lastX = nowX
     lastY = nowY
  


  $(".control").bind "mouseout mouseup touchend touchchancel", ->    
    event.preventDefault()
    $( @  ).attr 
      r: 8
    if @ is dragging
      dragging = undefined
