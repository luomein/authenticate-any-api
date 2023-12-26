//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/27.
//

import Foundation

public extension AAATwitter{
    static func AuthorizationUrl(redirect_uri: URL, client_id: String, scope : [Scope]? = nil,  state : String
                                    , code_challenge_method : String
                                    , code_challenge : String 
    ) -> URL{
        let base_url = "https://twitter.com/i/oauth2/authorize"
        let convertScope : ([Scope]) -> String = { $0.map({$0.rawValue}).joined(separator: " ") }
        var queryItems : [URLQueryItem] = [
            URLQueryItem(name: "client_id" , value: client_id),
            URLQueryItem(name: "redirect_uri" , value: redirect_uri.absoluteString),
            URLQueryItem(name: "response_type" , value: Const.responseType),
            URLQueryItem(name: "code_challenge_method" , value: code_challenge_method),
            URLQueryItem(name: "code_challenge" , value: code_challenge),
            URLQueryItem(name: "state", value: state)
       ]
        if let scope = scope, !scope.isEmpty{
            queryItems.append(URLQueryItem(name: "scope", value: convertScope(scope)))
        }
         
        
        var components = URLComponents(string: base_url)!
        components.queryItems = queryItems
        return components.url!
    }
}
