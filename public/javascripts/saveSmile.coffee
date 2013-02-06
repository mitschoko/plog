$(document).ready ->
  window.saveSmile = ( smile ) ->  
    data = [ ]
    concatenate_class = ( element ) ->
      el_class = $(element).attr("class")
      if el_class?
        el_class.split(" ").join(".") 
      else
        " "
    $(smile).children().map -> 
      data.push concatenate_class( @  )   
    console.log( data.join(" -- "))
      
  
      
