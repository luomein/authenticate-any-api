//
//  OpenAPIClientRequestReducerTests.swift
//  
//
//  Created by MEI YIN LO on 2023/12/25.
//

import XCTest
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

fileprivate protocol OpenAPIClientRequestProtocol:Equatable{
    associatedtype Client
    associatedtype Request
    associatedtype Response : Equatable
    var client : Client {get}
    var request: Request {get}
    static func fetchOpenAPI(clientRequest: Self)async throws->Response
}
final class OpenAPIClientRequestTests: XCTestCase {
    struct SpotifyTokenOpenAPIClientRequest : OpenAPIClientRequestProtocol{
        var client : Client {
            return Client(
                serverURL: try! Servers.server1(),
                transport: URLSessionTransport(),
                middlewares: [AuthenticationMiddleware(clientId: Credential.SpotifyAuth.client_id, clientSecret: Credential.SpotifyAuth.client_secret)]
            )
        }
        var request: Components.Schemas.access_token_request{
            return Components.Schemas.access_token_request.init(grant_type: "client_credentials")
        }
        static func fetchOpenAPI(clientRequest: Self)async throws->Components.Schemas.access_token_response{
            let tokenResponse = try await clientRequest.client.api_sol_token(body: .urlEncodedForm(clientRequest.request))
            switch tokenResponse{
            case .ok(let okResponse):
                guard case .json(let jsonBody) = okResponse.body else{fatalError()}
                return jsonBody//.access_token
            case .undocumented(statusCode: let statusCode, _):
                print("🥺 undocumented response: \(statusCode)")
                fatalError()
            }
        }
    }
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
            let key = Data("\(clientId):\(clientSecret)".utf8).base64EncodedString()
            request.headerFields[.authorization] = "Basic \(key)"
            return try await next(request, body, baseURL)
        }
    }
    func testClientCredentials()async throws{
        let clientRequest = SpotifyTokenOpenAPIClientRequest()
        let response = try await SpotifyTokenOpenAPIClientRequest.fetchOpenAPI(clientRequest: clientRequest)
        print(response)
    }
}
