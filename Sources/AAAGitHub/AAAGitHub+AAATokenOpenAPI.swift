//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/12/4.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import AAA

extension AAAGitHub : AAATokenUrl{
    
    
    public func requestToken(authorizedCode: String?) -> OpenAPIClientRequest {
        switch self {
        case .github_app_user_access_token_webflow,
                .oauth_app_user_access_token_webflow:
            return .request_token(code: authorizedCode!, authFlow: self)
        }
    }
    
    public func refreshToken(refreshToken: String?) -> OpenAPIClientRequest {
        fatalError()
    }
    
    public var canRefreshToken : Bool{
        switch self {
        case .github_app_user_access_token_webflow:
            return true
        case .oauth_app_user_access_token_webflow:
            return false
        }
    }
    
}
