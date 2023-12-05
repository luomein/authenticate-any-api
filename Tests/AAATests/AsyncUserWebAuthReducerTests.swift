//
//  AsyncUserWebAuthReducerTests.swift
//  
//
//  Created by MEI YIN LO on 2023/12/3.
//

import XCTest
import AAA
import AAAGitHub
import AAASpotify
import ComposableArchitecture

@MainActor
@available(macOS 13.0, *)
final class AsyncUserWebAuthReducerTests: XCTestCase {
    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let prefersEphemeralWebBrowserSession = false
    let dummyCode = "dummyCode"
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    typealias Reducer = AsyncUserWebAuthReducer
    typealias State = Reducer.State
    
    func fetchWrapper(input: Sendable) async throws -> Sendable{
        let response = try await AsyncUserWebAuthAgent.authFlow(parameter: input as! AsyncUserWebAuthAgent.Parameter)
        print(response)
        return dummyCode
    }
    func testReducer(parameter : AsyncUserWebAuthAgent.Parameter) async throws{
        let store = TestStore(initialState: State(debounceDuration:debounceDuration  )) {
            Reducer(fetchUserWebAuthClient: AsyncRequestClient(fetch: fetchWrapper) )
        } withDependencies: {
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
            
        }
        await store.send(.userWebAuth(parameter))
        await store.receive(.joinActionAsyncRequestReducer(.debounceQueuedRequest(request: parameter)), timeout: .seconds(5))
        await store.receive(.joinActionAsyncRequestReducer(.response(.success(dummyCode))), timeout: .seconds(25)){
            $0.joinStateAsyncRequestReducer.response = self.dummyCode
        }
        await store.receive(.receive(authorizedCode: dummyCode)){
            $0.authorizedCode = self.dummyCode
        }
//        await store.receive(.response(.success(true)), timeout: .seconds(5)){
//            $0.response = true
//        }
        
    }

    func testGitHub() async throws {
        typealias credential = Credential.GithubAuth
        typealias AAA = AAAGitHub
        let allow_signup = true
        let login = "test"
        let url = AAA.UserWebAuthURL(redirect_uri: credential.redirect_uri
                                           , client_id: credential.client_id
                                           , scope: [.repo,.user]
                                     , login: login
                                     , allow_signup : allow_signup)
        let parameter = AsyncUserWebAuthAgent.Parameter(url: url
                                                        , redirect_uri: credential.redirect_uri
                                                        , prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession, response_type: AAA.Const.responseType)
        //let response = try await AsyncUserWebAuthAgent.authFlow(parameter: parameter)
        //print(response)
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
                                                        , prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession, response_type: AAA.Const.responseType)
//        let response = try await AsyncUserWebAuthAgent.authFlow(parameter: parameter)
//        print(response)
        try await testReducer(parameter: parameter)
    }


}
