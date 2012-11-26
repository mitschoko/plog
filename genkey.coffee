alphanum = "qwertzuiopasdfghjklyxcvbnm1234567890QWERTZUIOASDFGHJKLYXCVBNM"
randAlphaNum = -> alphanum[ Math.floor( Math.random() * alphanum.length ) ]
randAlphaNumKey  = ( len ) -> ( randAlphaNum() for i in [0 ... len] ).join( "" ) 
keychars = alphanum + "$.-_+*?!()=<>;:#~[{]}%&"
randKeyChar = -> keychars[ Math.floor( Math.random() * keychars.length ) ]
randKey  = ( len ) -> ( randKeyChar() for i in [0 ... len] ).join( "" ) 
exports.genAlphaNumKey = randAlphaNumKey
exports.genKey = randKey
