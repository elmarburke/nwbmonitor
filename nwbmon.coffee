http = require 'http'

host = 'www.nordwestbahn.de'
port = '80'

stationId = (station, callback) ->
  data = "input=#{encodeURI station}&eID=tx_elementeabfahrtsmonitor_pi1"
  
  option =
      host: host
      port: port
      path: '/de/verkehrsmeldungen/abfahrtsmonitor.html'
      method: 'POST'
      headers:
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'
        'Content-Length': data.length
  
  req = http.request option, (response) ->
    str = '' # Cache the response during getting data
    
    response.on 'data', (chunk) ->
      str += chunk
    
    response.on 'end', ->
      
      # regexp to extract all stationnames
      reg = /<li id="(\w{0,4})"><strong>(.{0,18})<\/strong>((\w+|-+|\s|[öäüÖÄÜ\(\)]+)*)<\/li>/ig
      values = [] # hold all stations
      search = '' # some foo (dont know why i did this)
      
      while search = reg.exec(str)
        name = search[2]
        if search[3]? then name += search[3]
        
        obj =
          id: search[1]
          name: search[2] + search[3]
        
        values.push(obj)
      
      callback(null, values)
  
  req.write data # send the POST request
  req.end() # close the connection

exports.stationId = stationId

timetable = (stationId, callback) ->
  data = "id=#{encodeURI stationId}"
  option =
      host: host
      port: port
      path: '/de/verkehrsmeldungen/abfahrtsmonitor/ajax.html'
      method: 'POST'
      headers:
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'
        'Content-Length': data.length
  
  req = http.request option, (response) ->
    str = '' # Cache the response during getting data
    
    response.on 'data', (chunk) ->
      str += chunk
    
    response.on 'end', () ->
      timetable = [] # takes the departures
      reg = /<td class="erste-Zelle">(\d{2}:\d{2})<\/td>(\n|\s)*<td>(\d{2}:\d{2})?<\/td>(\n|\s)*<td>(\n|\s)*(\d{5})(\n|\s)*-\s((RE|RB|RS|KBS)\s\d+)(<br\/>(.*))?(\n|\s|<\/?td>)*<h4>(.*)<\/h4>/igm
      
      while results = reg.exec str
        obj =
          std: results[1]
          trainId: results[6]
          number:
            id: results[8]
          dest: results[13]
        
        obj.number.name = results[10] if results[10]?
        obj.etd = results[3] if results[3]?
        
        timetable.push obj
      
      callback null, timetable
  
  req.write data # send the POST request
  req.end() # close the connection

exports.timetable = timetable