//
//  TokenUrlReducerTests.swift
//  
//
//  Created by MEI YIN LO on 2023/12/26.
//

import XCTest
import AAA
import AAATwitter
import ComposableArchitecture

@MainActor
@available(macOS 13.0, *)
final class TokenUrlReducerTests: XCTestCase {

    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let prefersEphemeralWebBrowserSession = false
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    typealias Reducer = TokenUrlReducer<AAATwitter.TokenUrl>
    typealias State = Reducer.State
   
    func testReducer() async throws {
        let authFlow = AAATwitter.clientCredentials(consumer_api_key: Credential.TwitterAuth.consumer_api_key, consumer_api_secret: Credential.TwitterAuth.consumer_api_secret)
        let store =  Store(initialState: State(debounceDuration: debounceDuration)) {
            Reducer()
        }withDependencies: { [self] in
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        await store.send(.asyncCall(authFlow.requestToken(authorizedCode: nil))).finish()
        let code = store.withState{state in
            return state.response?.access_token
        }
        print(code)
    }
}
