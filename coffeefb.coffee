qs = require 'querystring'
url_parser = require 'url'
request = require 'request'
auth = require 'auth'

class Coffeefb

    constructor: (app_id) ->

        @FACEBOOK_URL = "https://www.facebook.com/"
        @GRAPH_URL = "https://graph.facebook.com/"
        @BASE_AUTH_URL = "#{@GRAPH_URL}oauth/authorize?"
        @BASE_TOKEN_URL = "#{@GRAPH_URL}oauth/access_token?"
        @app_id = app_id
        @permissions = null

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

    _build_url: (path, params) ->

        return "#{path}#{@_get_url_path(params)}"

    _make_request: (host, params, callback) ->

        url = @_build_url(host, params)

        request.get {url:url}, (e, r, body) ->
            callback(body)

    _make_post_request: (host, params, callback) ->

        path = @_get_url_path(params)

        request.post {url:host, body:path}, (e, r, body) ->
            callback(body)

    set_permisions: (permissions) ->

        @permissions = permissions

    _get_default_scope: () ->

        [p for p of auth].join(",")

    get_auth_code_url: (redirect_uri) ->

        if not @permissions
            @_get_default_scope()

        params = {
            "client_id": @app_id,
            "scope": auth
        }
        return @_get_auth_url params, redirect_uri

    _is_empty: (obj) ->
        (p for p of obj).length == 0

    api: (method, params, callback) ->

        access_token = params["access_token"]
        delete params["access_token"]

        url = "#{@GRAPH_URL}#{method}?access_token=#{access_token}"

        if (@_is_empty(params))
            return @_make_request url, {}, callback

        @_make_post_request url, params, callback


exports = module.exports = Coffeefb
