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


extension AAATwitter: AAATokenUrl{
    
    
    public var canRefreshToken : Bool{
        switch self {
        case  .authorization_code_PKCE:
            return true
        case .clientCredentials:
            return false
        }
    }
    
    public func requestToken(authorizedCode: String?)->TokenUrl{
        return .request_token(code: authorizedCode, authFlow: self)
    }
    public func refreshToken(refreshToken: String?)->TokenUrl{
        guard canRefreshToken, let refreshToken = refreshToken else{
            fatalError()
        }
        return .refresh_token(refresh_token: refreshToken, authFlow: self)

    }
    
}
