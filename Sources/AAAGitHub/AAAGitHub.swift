//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation


public struct AAAGitHub{
    public enum Scope:String{
        case repo = "repo"
        case user = "user"
    }
    public static var responseType = "code"
    public static func userWebAuthURL(redirect_uri: URL, client_id: String, scope : [Scope]) -> URL{
        let base_url = "https://github.com/login/oauth/authorize"
        let convertScope : ([Scope]) -> String = { $0.map({$0.rawValue}).joined(separator: " ") }
        let queryItems : [URLQueryItem] = [
            URLQueryItem(name: "client_id" , value: client_id),
            URLQueryItem(name: "redirect_uri" , value: redirect_uri.absoluteString),
            URLQueryItem(name: "response_type" , value: AAAGitHub.responseType),
            URLQueryItem(name: "scope", value: convertScope(scope))
       ]
        var components = URLComponents(string: base_url)!
        components.queryItems = queryItems
        return components.url!
    }
}
