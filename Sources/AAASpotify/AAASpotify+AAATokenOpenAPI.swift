//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation
import AAA
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes


extension AAASpotify: AAATokenOpenAPI{
    
    
    public var canRefreshToken : Bool{
        switch self {
        case .authorization_code, .authorization_code_PKCE:
            return true
        case .clientCredentials:
            return false
        }
    }
    
    public func requestToken(authorizedCode: String?)->OpenAPIClientRequest{
        return .request_token(code: authorizedCode!, authFlow: self)
    }
    public func refreshToken(refreshToken: String?)->OpenAPIClientRequest{
        guard canRefreshToken, let refreshToken = refreshToken else{
            fatalError()
        }
        return .refresh_token(refresh_token: refreshToken, authFlow: self)

    }
    
}
