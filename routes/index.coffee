
exports.index = (req, res) ->
  res.render 'index',
    title: "hello World!"
    posts: [
        text: "blubb blubb"
        time: "12.4.2002 12:34"
      ,
        text: "laber rahbaber"
        time: "4.6.2003 3:33"
      ] 
