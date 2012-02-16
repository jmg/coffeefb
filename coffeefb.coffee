qs = require 'querystring'
url_parser = require 'url'
request = require 'request'

class Coffeefb

    constructor: (app_id) ->

        @FACEBOOK_URL = "https://www.facebook.com/"
        @GRAPH_URL = "https://graph.facebook.com/"
        @BASE_AUTH_URL = "#{@GRAPH_URL}oauth/authorize?"
        @BASE_TOKEN_URL = "#{@GRAPH_URL}oauth/access_token?"
        @app_id = app_id

    _get_url_path: (dic) ->

        return qs.stringify(dic)

    _get_auth_url: (params, redirect_uri) ->

        params['redirect_uri'] = redirect_uri

        url_path = @_get_url_path(params)
        url = "#{@BASE_AUTH_URL}#{url_path}"
        return url

    get_access_token: (app_secret_key, secret_code, redirect_uri, callback) ->

        params = {
            "client_id": @app_id,
            "client_secret" : app_secret_key,
            "redirect_uri" : redirect_uri,
            "code" : secret_code,
        }

        data = @_make_request @BASE_TOKEN_URL, params, (body) ->

            data = qs.parse body
            access_token = data['access_token']
            callback(access_token)

    _make_auth_request: (access_token, path, params, callback) ->

        url = "#{@GRAPH_URL}#{path}?"
        params['access_token'] = access_token
        @_make_request url, params, callback

    _build_url: (path, params) ->

        return "#{path}#{@_get_url_path(params)}"

    _make_request: (host, params, callback) ->

        url = @_build_url(host, params)

        request.get {url:url}, (e, r, body) ->
            callback(body)

    get_auth_code_url: (redirect_uri) ->

        params = {
            "client_id": @app_id,
            "scope": "user_about_me, email"
        }
        return @_get_auth_url params, redirect_uri

    api: (access_token, method, params, callback) ->

        @_make_auth_request access_token, method, params, callback


exports = module.exports = Coffeefb
