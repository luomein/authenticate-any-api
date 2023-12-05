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
import AAATwitter
import ComposableArchitecture

@MainActor
@available(macOS 13.0, *)
final class BaseAsyncRequestReducerTests: XCTestCase {
    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    typealias Reducer = BaseAsyncRequestReducer<AsyncUserWebAuthAgent.Parameter,Bool>
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
        await store.send(.debounceQueuedRequest(request: parameter)).finish()
        await store.receive(.response(.success(true)), timeout: .seconds(5)){
            $0.response = true
        }
    }

    func testGitHub() async throws {
        typealias credential = Credential.GithubAuth
        typealias AAA = AAAGitHub
        let url = AAA.UserWebAuthURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                           , scope: [.repo,.user])
        let parameter = AsyncUserWebAuthAgent.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: false, response_type: AAA.Const.responseType)
        try await testReducer(parameter: parameter)
    }
    func testSpotify() async throws {
        typealias credential = Credential.SpotifyAuth
        typealias AAA = AAASpotify
        let url = AAA.UserWebAuthURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                           )
        let parameter = AsyncUserWebAuthAgent.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: false, response_type: AAA.Const.responseType)
        try await testReducer(parameter: parameter)
    }
    func testTwitter() async throws {
        typealias credential = Credential.TwitterAuth
        typealias AAA = AAATwitter
        let code_challenge = "code_challenge"
        let state = "state"
        let url = AAA.UserWebAuthURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                     , scope: [.follows_read, .offline_access, .tweet_read]
                                     , state: state
                                     , code_challenge_method: AAA.Const.codeChallengeMethod
                                     , code_challenge: code_challenge
                                           )
        print(url)
        let parameter = AsyncUserWebAuthAgent.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: false, response_type: AAA.Const.responseType)
        try await testReducer(parameter: parameter)
    }

}
