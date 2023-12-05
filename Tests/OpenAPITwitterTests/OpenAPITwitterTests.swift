
//  
//
//  Created by MEI YIN LO on 2023/12/4.
//

import XCTest
import AAA
import AAATwitter
import ComposableArchitecture

@MainActor
@available(macOS 13.0, *)
final class OpenAPITwitterTests: XCTestCase {
    let debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 0.1
    let prefersEphemeralWebBrowserSession = false
    let code_challenge = "code_challenge"
    let state = "state"
    let testQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.main
    typealias Reducer = AAAFlowReducer<AAATwitter>
    typealias State = Reducer.State

    
    func testReducer() async throws {
        let authFlow = AAATwitter.authorization_code_PKCE(client_id: Credential.TwitterAuth.client_id, redirect_uri: Credential.TwitterAuth.redirect_uri, code_challenge: code_challenge, code_verifier: code_challenge, scope: [.follows_read,.offline_access,.tweet_read, .users_read], state: state)
        let store : StoreOf<Reducer> = .init(initialState: State.init(authFlow: authFlow
                                                                      , prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession
                                                                      , debounceDuration: debounceDuration)) {
            Reducer()
        } withDependencies: { [self] in
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        }
        await store.send(.auth).finish()
        let access_token = store.withState { state in
            print(state.accessTokenResponse )
            return state.accessTokenResponse!.access_token
        }
        //print(access_token)
        let client = OpenAPITwitterClient(accessToken: access_token)
        let response  = try! await client.findMyUser()
        print(response)
    }

}
