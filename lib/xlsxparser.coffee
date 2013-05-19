_     = require 'lodash'
fs    = require 'fs'
XLSX  = require './xlsx'

module.exports = (path, callback)->

  console.log "\n\n---------- BEFORE PARSING XML FILE (#{path})... ------------\n\n"
  t = Date.now()

  xlsx = XLSX.readFile path, type: 'binary'

  console.log 'XLSX after read: ' + ((Date.now() - t) / 1000) + 's'

  currentSheet = xlsx.Sheets[xlsx.SheetNames[0]]
  currentSheetArray = XLSX.utils.sheet_to_array currentSheet


  console.log '---------- XLSX DONE PARSING XML FILE... ------------'
  console.log '---------- est. time: ' + (Date.now() - t) / 1000 + 's ------------'

  callback? currentSheetArray