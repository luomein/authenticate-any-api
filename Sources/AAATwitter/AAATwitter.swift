//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation

///
///https://developer.twitter.com/en/docs/authentication/oauth-2-0/user-access-token
///
public enum AAATwitter: Equatable{
    //case authorization_code(client_id: String, client_secret: String, redirect_uri: URL, scope : [Scope]?, state: String?)
    case authorization_code_PKCE(client_id: String, redirect_uri: URL,  code_challenge: String, code_verifier: String, scope : [Scope]?, state: String)
    
    //https://developer.twitter.com/en/docs/authentication/oauth-2-0/application-only
    case clientCredentials(consumer_api_key: String, consumer_api_secret: String)
    

    
    
    
}
