//
//  AsyncRequestResponseReducerTests.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import XCTest
import AAA
import AAAGitHub
import AAASpotify
import ComposableArchitecture

@MainActor
@available(macOS 13.0, *)
final class AsyncRequestResponseReducerTests: XCTestCase {
    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    typealias Reducer = AsyncRequestResponseReducer<AsyncUserWebAuthAgent.Parameter,Bool>
    typealias State = Reducer.State
    
    func fetchWrapper(input: Sendable) async throws -> Sendable{
        let response = try await AsyncUserWebAuthAgent.authFlow(parameter: input as! AsyncUserWebAuthAgent.Parameter)
        print(response)
        return !response.isEmpty
    }

    func testReducer(parameter : AsyncUserWebAuthAgent.Parameter) async throws{
        let store = TestStore(initialState: State(debounceDuration:debounceDuration  )) {
            Reducer()
        } withDependencies: {
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
            $0.asyncRequestClient = AsyncRequestClient(fetch: fetchWrapper)
        }
        await store.send(.debounceQueuedRequest(request: parameter))
        await store.receive(.response(.success(true)), timeout: .seconds(5)){
            $0.response = true
        }
    }

    func testGitHub() async throws {
        typealias credential = Credential.GithubAuth
        typealias AAA = AAAGitHub
        let url = AAA.userWebAuthURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                           , scope: [.repo,.user])
        let parameter = AsyncUserWebAuthAgent.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: false, response_type: AAA.responseType)
        try await testReducer(parameter: parameter)
    }
    func testSpotify() async throws {
        typealias credential = Credential.SpotifyAuth
        typealias AAA = AAASpotify
        let url = AAA.userWebAuthURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                           )
        let parameter = AsyncUserWebAuthAgent.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: false, response_type: AAA.Const.responseType)
        try await testReducer(parameter: parameter)
    }

}
