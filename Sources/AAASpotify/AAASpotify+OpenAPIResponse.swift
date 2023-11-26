//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import AAA

public extension AAASpotify{
    typealias OpenAPIResponse = Components.Schemas.access_token_response
}
extension Components.Schemas.access_token_response : TokenRefreshable{
    
}
