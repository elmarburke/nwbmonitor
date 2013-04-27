twitter    = require 'ntwitter'
http       = require 'http'
stationId  = require './nwbmon'

twit = new twitter
  consumer_key: '3YWX8hsTrEnGGeHeImIysdbMw'
  consumer_secret: 'VdasTrEnGGeHeImljbQsgOGwgbCwRJd6J9xVucaVL8'
  access_token_key: '11sTrEnGGeHeImjsfaa8W2062tWUOJbQS0c2BBtSY9ErF4B3oG'
  access_token_secret: 'sTrEnGGeHeImlotvVoVVHNkpsyVtgiudCaVI9BCga0'

twit.stream 'user', replies: "all", (stream) ->
  stream.on 'data', (data) ->
    #console.log data
    if data.text? and data.id? and /^@NWBMonitor/i.test(data.text) and data.user.screen_name isnt "NWBMonitor"
      
      tweetContent = getTweetContent data
      getResponse tweetContent, (err, response) ->
        if err
          console.log err
          
          response.status = err.description
          response.in_reply_to_status_id = err.id
        
        twit.updateStatus response.status, 
          in_reply_to_status_id: response.in_reply_to_status_id,
          (err, data) ->
            console.log err if err?

getTweetContent = (tweet) ->
  contentRegExp = /\W*@NWBMonitor\W*/ig;
  
  content = tweet.text.replace contentRegExp, ""
  
  tweetContent = 
    id: tweet.id_str
    content: content
    user: tweet.user.screen_name

getResponse = (tweet, callback) ->
  
  stationId.stationId tweet.content, (err, data) ->
    if err or typeof data isnt "object" or data.length < 1
      err = new Object unless err
      err.description = "@#{tweet.user} Konnte Bahnhof #{tweet.content} nicht finden. Das tut mir leid."
      err.id = tweet.id
      callback(err || "No Array", null)
      return
    
    stationId.timetable data[0].id, (err, timetable) ->
      maxConnection = if timetable.length >= 2 then 2 else timetable.length
      text = ''
      
      for i in [0..maxConnection-1]
        text += "#{timetable[i].number.id} nach #{timetable[i].dest} um #{timetable[i].std}"
      
        if timetable[i].etd
          text += " fährt ab um #{timetable[i].etd} "
        else
          text += " hat noch keine Daten. "
      
      if text.length == 0
        text = "In der nächsten Zeit kommt wohl kein Zug mehr in #{tweet.content}. Gehe zu Fuß, fahre mit dem Rad oder nimm ein Taxi. Viel Glück. "
      
      now = new Date()
      time = "#{now.getHours() + 1}:#{now.getMinutes()}:#{now.getSeconds()}"
      
      status = "@#{tweet.user} #{text} - Daten #{time}"
      
      status = status.replace /(\(|\))/img, ""
      
      if status.length >= 140
        status = status.slice(0,138) + "…"
      
      callback null, 
        status: status,
        in_reply_to_status_id: tweet.id