http = require 'http'
qs = require 'querystring'
url_parser = require 'url'

class Coffeefb

    constructor: (app_id) ->

        @FACEBOOK_URL = "https://www.facebook.com/"
        @GRAPH_URL = "https://graph.facebook.com/"
        @BASE_AUTH_URL = "#{@GRAPH_URL}oauth/authorize?"
        @app_id = app_id

    _get_url_path: (dic) ->

        return qs.stringify(dic)

    _get_auth_url: (params, redirect_uri) ->

        params['redirect_uri'] = redirect_uri

        url_path = @_get_url_path(params)
        url = "#{@BASE_AUTH_URL}#{url_path}"
        return url

    get_access_token: (app_secret_key, secret_code, redirect_uri) ->

        params = {
            "client_id": @app_id,
            "client_secret" : app_secret_key,
            "redirect_uri" : redirect_uri,
            "code" : secret_code,
        }

        data = @_make_request @BASE_TOKEN_URL, params, (res) ->

            data = qs.parse res
            @access_token = data['access_token']
            @expires = data['expires']

    _make_auth_request: (path, params, callback) ->

        params['access_token'] = @access_token
        @_make_request @GRAPH_URL, params, callback

    _make_request: (host, params, callback) ->

        path = @_get_url_path(params)

        data = {
            host: host,
            path: path
        }

        http.get data, (res) ->
            callback(res)

    get_auth_code_url: (redirect_uri) ->

        params = {
            "client_id": @app_id,
        }
        return @_get_auth_url params, redirect_uri


exports = module.exports = Coffeefb
