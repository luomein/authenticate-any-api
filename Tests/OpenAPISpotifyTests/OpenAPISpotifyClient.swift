//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/27.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

struct AuthenticationMiddleware: ClientMiddleware {


    /// The token value.
    var accessToken: String


    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[.authorization] = "Bearer \(accessToken)"
        return try await next(request, body, baseURL)
    }
}
public func OpenAPISpotifyClient(accessToken: String)->Client{
    return  Client(
        serverURL: try! Servers.server1(),
                    transport: URLSessionTransport(),
                    middlewares: [AuthenticationMiddleware(accessToken: accessToken)]
                )
}
