ApiClient = require '../../lib/ApiClient'
whenjs = require 'when'
request = require 'request'

class ApiClientFail extends ApiClient
  constructor: (baseUrl, access_token) ->
    super baseUrl, access_token

  login: (client_id, user, pass) =>
    dfd = whenjs.defer()
    request {
        uri: 'http://httpbin.org/delay/1'
    }, (error, response, body) ->
      dfd.reject 'Unknown user'

    dfd.promise

  listDevices: =>
    dfd = whenjs.defer()
    request {
        uri: 'http://httpbin.org/delay/1'
    }, (error, response, body) ->
      dfd.resolve {
        "code": 400,
        "error": "invalid_grant",
        "error_description": "The access token provided is invalid."
      }
    dfd.promise


module.exports = ApiClientFail
