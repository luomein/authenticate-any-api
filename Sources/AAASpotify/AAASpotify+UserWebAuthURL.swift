//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/27.
//

import Foundation

public extension AAASpotify{
    static func UserWebAuthURL(redirect_uri: URL, client_id: String, scope : [Scope]? = nil,  state : String? = nil
                                    , code_challenge_method : String? = nil
                                    , code_challenge : String? = nil
    ) -> URL{
        let base_url = "https://accounts.spotify.com/authorize"
        let convertScope : ([Scope]) -> String = { $0.map({$0.rawValue}).joined(separator: " ") }
        var queryItems : [URLQueryItem] = [
            URLQueryItem(name: "client_id" , value: client_id),
            URLQueryItem(name: "redirect_uri" , value: redirect_uri.absoluteString),
            URLQueryItem(name: "response_type" , value: Const.responseType),
            
       ]
        if let scope = scope, !scope.isEmpty{
            queryItems.append(URLQueryItem(name: "scope", value: convertScope(scope)))
        }
        if let state = state{
            queryItems.append(URLQueryItem(name: "state", value: state))
        }
        if let code_challenge{
            queryItems.append(URLQueryItem(name: "code_challenge_method" , value: code_challenge_method!))
            queryItems.append(URLQueryItem(name: "code_challenge" , value: code_challenge))
        }
        var components = URLComponents(string: base_url)!
        components.queryItems = queryItems
        return components.url!
    }
}
