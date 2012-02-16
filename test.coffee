url_parser = require 'url'
http = require 'http'
Coffeefb = require('./coffeefb')

Test =
    write: (s) ->
        console.log s

    assert: (b, message...) ->
        @write(if b then "pass" else "fail: #{message}")

    exec: (tests) ->
        for t in tests
            @write(t.name)
            t.func()

tests = []

tests.push {
    name: "Url Auth Code"
    func: () ->
        fb = new Coffeefb 248161555263929
        url_ok = "https://graph.facebook.com/oauth/authorize?client_id=248161555263929&redirect_uri=http%3A%2F%2Fwww.chatbook.local"
        Test.assert(fb.get_auth_code_url("http://www.chatbook.local") == url_ok)
}

tests.push {
    name: "Access token"
    func: () ->
        fb = new Coffeefb 248161555263929
        url = fb.get_auth_code_url("http://www.chatbook.local")

        parsed = url_parser.parse url

        http.get {host: parsed.host, path: parsed.path}, (res) ->
            Test.assert(res.statusCode == 302)
}

Test.exec(tests)
