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

public struct AAAFlowReducer<Flow: AAAFlow>: Reducer where Flow.OpenAPIClientRequest.Response : AAARefreshableToken {
    @Dependency(\.errorHandler) var errorHandler
    var fetchOpenAPIClient : AsyncCallClient
    var fetchUserWebAuthClient : AsyncCallClient
    public typealias T = Flow.OpenAPIClientRequest
    
    public init(fetchOpenAPIClient: AsyncCallClient = .init(fetch: OpenAPIClientRequestReducer<T>.fetchOpenAPI(input:))
                , fetchUserWebAuthClient: AsyncCallClient = .init(fetch: AuthorizationUrlReducer.fetchAuthorizationUrl(input:))) {
        self.fetchOpenAPIClient = fetchOpenAPIClient
        self.fetchUserWebAuthClient = fetchUserWebAuthClient
    }
    public struct State:Equatable{
        public var authFlow : Flow
        public var prefersEphemeralWebBrowserSession: Bool
        public var refreshToken: String? = nil
        public var accessTokenResponse : T.Response? = nil
        public var joinStateOpenAPIClientRequestReducer : OpenAPIClientRequestReducer<T>.State
        public var joinStateAsyncUserWebAuthReducer : AuthorizationUrlReducer.State
        public init(authFlow: Flow,prefersEphemeralWebBrowserSession: Bool
                    ,debounceDuration : DispatchQueue.SchedulerTimeType.Stride) {
            self.authFlow = authFlow
            self.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
            self.joinStateOpenAPIClientRequestReducer = .init(debounceDuration: debounceDuration)
            self.joinStateAsyncUserWebAuthReducer = .init(debounceDuration: debounceDuration)
        }
    }
    public enum Action:Equatable{
        case auth
        case refreshToken
        case joinActionOpenAPIClientRequestReducer(OpenAPIClientRequestReducer<T>.Action)
        case joinActionAsyncUserWebAuthReducer(AuthorizationUrlReducer.Action)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinStateOpenAPIClientRequestReducer, action: /Action.joinActionOpenAPIClientRequestReducer) {
            OpenAPIClientRequestReducer<T>.init(asyncCallClient: fetchOpenAPIClient)
            
        }
        Scope(state: \.joinStateAsyncUserWebAuthReducer, action: /Action.joinActionAsyncUserWebAuthReducer) {
            AuthorizationUrlReducer(
                asyncCallClient: fetchUserWebAuthClient
                )
            
        }
        Reduce { state, action in
            switch action {
            case .auth:
                if state.authFlow.needUserWebAuth{
                    let parameter =  state.authFlow.userWebAuthParameter(prefersEphemeralWebBrowserSession: state.prefersEphemeralWebBrowserSession)!
                    return .send(.joinActionAsyncUserWebAuthReducer(.asyncCall( parameter)))
                }
                else{
                    let clientRequest = state.authFlow.requestToken(authorizedCode: nil)
                    return .send(.joinActionOpenAPIClientRequestReducer(.asyncCall(clientRequest)))
                }
            case .refreshToken:
                if state.authFlow.canRefreshToken{
                    let clientRequest = state.authFlow.refreshToken(refreshToken: state.refreshToken)
                    return .send(.joinActionOpenAPIClientRequestReducer(.asyncCall(clientRequest)))
                }
            case .joinActionOpenAPIClientRequestReducer(let subAction):
                switch subAction{
                case .receive(let response):
                    state.accessTokenResponse = response
                    if let refreshToken = state.accessTokenResponse?.refresh_token{
                        state.refreshToken = refreshToken
                    }
                default:
                    break
                }
            case .joinActionAsyncUserWebAuthReducer(let subAction):
                switch subAction{
                case .receive( let code ):
                    let clientRequest = state.authFlow.requestToken(authorizedCode: code)
                    return .send(.joinActionOpenAPIClientRequestReducer(.asyncCall(clientRequest)))
                default:
                    break
                }
            }
            return .none
        }
    }
}

