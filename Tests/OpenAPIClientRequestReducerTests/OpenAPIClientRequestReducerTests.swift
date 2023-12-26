//
//  OpenAPIClientRequestReducerTests.swift
//  
//
//  Created by MEI YIN LO on 2023/12/25.
//

import XCTest
import AAA
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import AAA
import ComposableArchitecture

@MainActor
final class OpenAPIClientRequestReducerTests: XCTestCase {
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
            let key = "\(clientId):\(clientSecret)".toBase64()
            request.headerFields[.authorization] = "Basic \(key)"
            return try await next(request, body, baseURL)
        }
    }
    typealias TestReducer = OpenAPIClientRequestReducer<SpotifyTokenOpenAPIClientRequest>
    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    let fakeResponse : Components.Schemas.access_token_response = .init(access_token: "")
    func fakeFetchOpenAPI(input: Sendable)async throws->Sendable{
        let clientRequest = input as! SpotifyTokenOpenAPIClientRequest
        let tokenResponse = try await clientRequest.client.api_sol_token(body: .urlEncodedForm(clientRequest.request))
        
        switch tokenResponse{
        case .ok(let okResponse):
            guard case .json(let jsonBody) = okResponse.body else{fatalError()}
            return fakeResponse//jsonBody//.access_token
        case .undocumented(statusCode: let statusCode, _):
            print("🥺 undocumented response: \(statusCode)")
            fatalError()
        }
    }
    func testClientCredentials()async throws{
        let clientRequest = SpotifyTokenOpenAPIClientRequest()
        let store = TestStore(initialState: TestReducer.State(debounceDuration: debounceDuration)
        ) {
            TestReducer(asyncCallClient: .init(fetch: fakeFetchOpenAPI))
        } withDependencies: {
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        await store.send(.asyncCall(clientRequest))
        await store.receive(.joinActionAsyncCallReducer(.debounceQueuedRequest(request: clientRequest)), timeout: .seconds(1))
        await store.receive(.joinActionAsyncCallReducer(.response(.success(fakeResponse))), timeout: .seconds(1)){
            $0.joinStateAsyncCallReducer.response = self.fakeResponse
        }
        await store.receive(.receive(fakeResponse), timeout: .seconds(1)){
            $0.response = self.fakeResponse
        }
        
    }

}
