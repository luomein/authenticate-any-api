//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/27.
//

import Foundation
import AAA


extension AAATwitter : AAAAuthorizationUrl{
    public var needAuthorizationUrl : Bool{
        switch self {
        case   .authorization_code_PKCE:
            return true
//        case .clientCredentials:
//            return false
        }
    }
    public func authorizationUrlParameter(prefersEphemeralWebBrowserSession: Bool) ->  AuthorizationUrl.Parameter?{
        guard needAuthorizationUrl else {return nil}
        switch self {

        case .authorization_code_PKCE(client_id: let client_id, redirect_uri: let redirect_uri,  code_challenge: let code_challenge, _, let scope, let state):
            let userWebAuthURL = Self.UserWebAuthURL(redirect_uri: redirect_uri
                                                     , client_id: client_id
                                                     , scope: scope
                                                     , state: state
                                                     , code_challenge_method: Const.codeChallengeMethod
                                                     , code_challenge: code_challenge
                                                     )
            return .init(url: userWebAuthURL, redirect_uri: redirect_uri, prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession, response_type: Const.responseType)
        default:
            return nil
        }
    }
}
