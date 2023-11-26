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

extension AAASpotify{
    struct AuthenticationMiddleware: ClientMiddleware {


        let clientId: String
        let clientSecret: String


        func intercept(
            _ request: HTTPRequest,
            body: HTTPBody?,
            baseURL: URL,
            operationID: String,
            next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
        ) async throws -> (HTTPResponse, HTTPBody?) {
            var request = request
            let key = "\(clientId):\(clientSecret)".toBase64()
            request.headerFields[.authorization] = "Basic \(key)"
            return try await next(request, body, baseURL)
        }
    }
}
