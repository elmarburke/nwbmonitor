nwbmon = require './nwbmon'

option '-s', '--station [STATION_NAME]', 'set the stationname for `test:stationid`'
task 'test:stationid', 'Test Station ID', (param) ->
  station = param.station or "Kleve"
  callback = (err, ids) ->
    console.log err || ids
  
  nwbmon.stationId(station, callback)
  

option '-i', '--stationid [STATION_ID]', 'set the station id for `test:timetable`'
task 'test:timetable', 'Test Timetable', (param) ->
  stationid = param.stationid or "KKLV"
  nwbmon.timetable stationid, (err, timetable) ->
    console.log err or timetable

    