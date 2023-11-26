//
//  AAASpotifyTests.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import XCTest
import AAA
import AAASpotify
import ComposableArchitecture

@MainActor
@available(macOS 13.0, *)
final class AAASpotifyTests: XCTestCase {
    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    typealias Reducer = AAAFlowReducer<AAASpotify>
    typealias State = Reducer.State
   
    let dummyAuthorizedCode = "dummyAuthorizedCode"
    let dummyAccessToken = "dummyAccessToken"
    func fetchDummyUserWebAuth(input: Sendable) async throws -> Sendable {
        
        return dummyAuthorizedCode
    }
    func fetchDummyOpenAPI(input: Sendable) async throws -> Sendable {
        let response : Reducer.OpenAPIResponseType = .init(access_token: dummyAccessToken)
        return response
    }
    func testReducer() async throws {
        let authFlow = AAASpotify.clientCredentials(client_id: Credential.SpotifyAuth.client_id, client_secret: Credential.SpotifyAuth.client_secret)
        let store =  TestStore(initialState: State(authFlow: authFlow, prefersEphemeralWebBrowserSession: false, debounceDuration: debounceDuration)) {
            Reducer(fetchOpenAPIClient: .init(fetch: fetchDummyOpenAPI(input:))
                    , fetchUserWebAuthClient: .init(fetch: fetchDummyUserWebAuth(input:)))
        }withDependencies: {
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        await store.send(.auth)
        await store.receive(.joinActionOpenAPIRequestResponseReducer(.debounceQueuedRequest(request:authFlow.requestToken(authorizedCode: nil))))
        await store.receive(.joinActionOpenAPIRequestResponseReducer(.response(.success(.init(access_token: dummyAccessToken))))){
            $0.joinStateOpenAPIRequestResponseReducer.response = .init(access_token: self.dummyAccessToken)
            $0.accessTokenResponse = .init(access_token: self.dummyAccessToken)
        }
    }

}
