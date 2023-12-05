//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation

///
///https://developer.spotify.com/documentation/web-api/concepts/authorization
///
public enum AAASpotify: Equatable{
    case authorization_code(client_id: String, client_secret: String, redirect_uri: URL, scope : [Scope]?, state: String?)
    case authorization_code_PKCE(client_id: String, redirect_uri: URL,  code_challenge: String, code_verifier: String, scope : [Scope]?, state: String?)
    case clientCredentials(client_id: String, client_secret: String)
    

    
    
    
}
