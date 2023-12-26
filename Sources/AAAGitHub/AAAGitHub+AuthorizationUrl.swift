//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/27.
//

import Foundation

public extension AAAGitHub{
    //https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-user-access-token-for-a-github-app
    static func UserWebAuthURL(redirect_uri: URL, client_id: String, scope : [Scope]? = nil
                               , state: String? = nil
                               , login : String? = nil
                               , allow_signup: Bool? = nil) -> URL{
        let base_url = "https://github.com/login/oauth/authorize"
        let convertScope : ([Scope]) -> String = { $0.map({$0.rawValue}).joined(separator: " ") }
        let boolString : (Bool) -> String = { $0 ? "true" : "false"}
        var queryItems : [URLQueryItem] = [
            URLQueryItem(name: "client_id" , value: client_id),
            URLQueryItem(name: "redirect_uri" , value: redirect_uri.absoluteString),
            //URLQueryItem(name: "response_type" , value: AAAGitHub.Const.responseType),
            //URLQueryItem(name: "scope", value: convertScope(scope))
       ]
        if let scope = scope, !scope.isEmpty{
            queryItems.append(URLQueryItem(name: "scope", value: convertScope(scope)))
        }
        if let state = state{
            queryItems.append(URLQueryItem(name: "state", value: state ))
        }
        if let login = login{
            queryItems.append(URLQueryItem(name: "login", value: login ))
        }
        if let allow_signup = allow_signup{
            queryItems.append(URLQueryItem(name: "allow_signup", value: boolString(allow_signup) ))
        }
        var components = URLComponents(string: base_url)!
        components.queryItems = queryItems
        return components.url!
    }
}
