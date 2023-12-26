//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/21.
//

import Foundation
import ComposableArchitecture
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

public struct AAAFlowReducer<Flow: AAAFlow>: Reducer where Flow.TokenUrl.Response : AAARefreshableToken {
    @Dependency(\.errorHandler) var errorHandler
    //var fetchOpenAPIClient : AsyncCallClient
    //var fetchUserWebAuthClient : AsyncCallClient
    public typealias T = Flow.TokenUrl
    
//    public init(fetchOpenAPIClient: AsyncCallClient = .init(fetch: OpenAPIClientRequestReducer<T>.fetchOpenAPI(input:))
//                , fetchUserWebAuthClient: AsyncCallClient = .init(fetch: AuthorizationUrlReducer.fetchAuthorizationUrl(input:))) {
//        self.fetchOpenAPIClient = fetchOpenAPIClient
//        self.fetchUserWebAuthClient = fetchUserWebAuthClient
//    }
    public init(){}
    public struct State:Equatable{
        public var authFlow : Flow
        public var prefersEphemeralWebBrowserSession: Bool
        public var refreshToken: String? = nil
        public var accessTokenResponse : T.Response? = nil
        public var joinStateTokenUrlReducer : TokenUrlReducer<T>.State
        public var joinStateAuthorizationUrlReducer : AuthorizationUrlReducer.State
        public init(authFlow: Flow,prefersEphemeralWebBrowserSession: Bool
                    ,debounceDuration : DispatchQueue.SchedulerTimeType.Stride) {
            self.authFlow = authFlow
            self.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
            self.joinStateTokenUrlReducer = .init(debounceDuration: debounceDuration)
            self.joinStateAuthorizationUrlReducer = .init(debounceDuration: debounceDuration)
        }
    }
    public enum Action:Equatable{
        case auth
        case refreshToken
        case joinActionTokenUrlReducer(TokenUrlReducer<T>.Action)
        case joinActionAuthorizationUrlReducer(AuthorizationUrlReducer.Action)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinStateTokenUrlReducer, action: /Action.joinActionTokenUrlReducer) {
            
                TokenUrlReducer<T>.init(
                    //    asyncCallClient: fetchOpenAPIClient
                )
            
            
        }
        Scope(state: \.joinStateAuthorizationUrlReducer, action: /Action.joinActionAuthorizationUrlReducer) {
            AuthorizationUrlReducer(
                //asyncCallClient: fetchUserWebAuthClient
                )
            
        }
        Reduce { state, action in
            switch action {
            case .auth:
                if state.authFlow.needAuthorizationUrl{
                    let parameter =  state.authFlow.authorizationUrlParameter(prefersEphemeralWebBrowserSession: state.prefersEphemeralWebBrowserSession)!
                    return .send(.joinActionAuthorizationUrlReducer(.asyncCall( parameter)))
                }
                else{
                    let clientRequest = state.authFlow.requestToken(authorizedCode: nil)
                    return .send(.joinActionTokenUrlReducer(.asyncCall(clientRequest)))
                }
            case .refreshToken:
                if state.authFlow.canRefreshToken{
                    let clientRequest = state.authFlow.refreshToken(refreshToken: state.refreshToken)
                    return .send(.joinActionTokenUrlReducer(.asyncCall(clientRequest)))
                }
            case .joinActionTokenUrlReducer(let subAction):
                switch subAction{
                case .receive(let response):
                    state.accessTokenResponse = response
                    if let refreshToken = state.accessTokenResponse?.refresh_token{
                        state.refreshToken = refreshToken
                    }
                default:
                    break
                }
            case .joinActionAuthorizationUrlReducer(let subAction):
                switch subAction{
                case .receive( let code ):
                    let clientRequest = state.authFlow.requestToken(authorizedCode: code)
                    return .send(.joinActionTokenUrlReducer(.asyncCall(clientRequest)))
                default:
                    break
                }
            }
            return .none
        }
    }
}

