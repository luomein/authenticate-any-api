//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/27.
//

import Foundation
import AAA

extension AAAGitHub: AAAAuthorizationUrl{
    public var needAuthorizationUrl : Bool{
        switch self {
        case .github_app_user_access_token_webflow,
                .oauth_app_user_access_token_webflow:
            return true
        }
    }
    public func authorizationUrlParameter(prefersEphemeralWebBrowserSession: Bool) ->  AuthorizationUrl.Parameter?{
        guard needAuthorizationUrl else {return nil}
        switch self {
        case .github_app_user_access_token_webflow(let client_id, _, let redirect_uri ):
            let userWebAuthURL = Self.UserWebAuthURL(redirect_uri: redirect_uri
                                                     , client_id: client_id
                                                     )
            return .init(url: userWebAuthURL, redirect_uri: redirect_uri, prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession, response_type: Const.responseType)
        case .oauth_app_user_access_token_webflow(let client_id, _, let redirect_uri ,
                                                  scope: let scope):
            let userWebAuthURL = Self.UserWebAuthURL(redirect_uri: redirect_uri
                                                     , client_id: client_id
                                                     , scope: scope
                                                     )
            return .init(url: userWebAuthURL, redirect_uri: redirect_uri, prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession, response_type: Const.responseType)
        }
    }
}
