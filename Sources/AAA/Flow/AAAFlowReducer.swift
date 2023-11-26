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


public struct AAAFlowReducer<Flow:AAAFlow>: Reducer{
    @Dependency(\.errorHandler) var errorHandler
    
    public typealias OpenAPIRequestType = Flow.OpenAPIClientRequest
    public typealias OpenAPIResponseType = Flow.OpenAPIResponse
    public typealias OpenAPIRequestResponseReducerType = AsyncRequestResponseReducer<OpenAPIRequestType,OpenAPIResponseType>
    public typealias UserWebAuthRequestResponseReducerType = AsyncRequestResponseReducer<AsyncUserWebAuthAgent.Parameter,String>
    var fetchOpenAPIClient : AsyncRequestClient
    var fetchUserWebAuthClient : AsyncRequestClient
    
    public init(fetchOpenAPIClient: AsyncRequestClient = .init(fetch: Self.fetchOpenAPI(input:))
                , fetchUserWebAuthClient: AsyncRequestClient = .init(fetch: Self.fetchUserWebAuth(input:))) {
        self.fetchOpenAPIClient = fetchOpenAPIClient
        self.fetchUserWebAuthClient = fetchUserWebAuthClient
    }
    public struct State:Equatable{
        public var authFlow : Flow
        public var prefersEphemeralWebBrowserSession: Bool
        public var refreshToken: String? = nil
        public var accessTokenResponse : OpenAPIResponseType? = nil
        public var joinStateOpenAPIRequestResponseReducer : OpenAPIRequestResponseReducerType.State
        public var joinStateUserWebAuthRequestResponseReducer : UserWebAuthRequestResponseReducerType.State
        public init(authFlow: Flow, prefersEphemeralWebBrowserSession: Bool
                    , debounceDuration : DispatchQueue.SchedulerTimeType.Stride) {
            self.authFlow = authFlow
            self.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
            self.joinStateOpenAPIRequestResponseReducer = .init(debounceDuration: debounceDuration)
            self.joinStateUserWebAuthRequestResponseReducer = .init(debounceDuration: debounceDuration)
        }
    }
    public enum Action:Equatable{
        case auth
        case refreshToken
        case joinActionOpenAPIRequestResponseReducer(OpenAPIRequestResponseReducerType.Action)
        case joinActionUserWebAuthRequestResponseReducer(UserWebAuthRequestResponseReducerType.Action)
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinStateOpenAPIRequestResponseReducer, action: /Action.joinActionOpenAPIRequestResponseReducer) {
            OpenAPIRequestResponseReducerType()
                .dependency(\.asyncRequestClient, fetchOpenAPIClient)
        }
        Scope(state: \.joinStateUserWebAuthRequestResponseReducer, action: /Action.joinActionUserWebAuthRequestResponseReducer) {
            UserWebAuthRequestResponseReducerType()
                .dependency(\.asyncRequestClient, fetchUserWebAuthClient)
        }
        Reduce { state, action in
            switch action {
            case .auth:
                if state.authFlow.needUserWebAuth{
                    let parameter =  state.authFlow.userWebAuthParameter(prefersEphemeralWebBrowserSession: state.prefersEphemeralWebBrowserSession)!
                    return .send(.joinActionUserWebAuthRequestResponseReducer(.debounceQueuedRequest(request: parameter)))
                }
                else{
                    let clientRequest = state.authFlow.requestToken(authorizedCode: nil)
                    return .send(.joinActionOpenAPIRequestResponseReducer(.debounceQueuedRequest(request: clientRequest)))
                }
                
                
            case .refreshToken:
                if state.authFlow.canRefreshToken{
                    let clientRequest = state.authFlow.refreshToken(refreshToken: state.refreshToken)
                    return .send(.joinActionOpenAPIRequestResponseReducer(.debounceQueuedRequest(request: clientRequest)))
                }
            case .joinActionOpenAPIRequestResponseReducer(let subAction):
                switch subAction{
                case .response(.success(let response)):
                    state.accessTokenResponse = response
                    if let refreshToken = state.accessTokenResponse?.refresh_token{
                        state.refreshToken = refreshToken
                    }
                    break
                default:
                    break
                }
            case .joinActionUserWebAuthRequestResponseReducer(let subAction):
                switch subAction{
                case .response(.success(let code)):
                    let clientRequest = state.authFlow.requestToken(authorizedCode: code)
                    return .send(.joinActionOpenAPIRequestResponseReducer(.debounceQueuedRequest(request: clientRequest)))
                default:
                    break
                }
            }
            return .none
        }
    }
}
extension AAAFlowReducer{
    public static func fetchOpenAPI(input: Sendable) async throws -> Sendable {
        let response = try await Flow.fetchRequest(clientRequest: input as! OpenAPIRequestType)
        return response
    }
    public static func fetchUserWebAuth(input: Sendable) async throws -> Sendable {
        let response = try await AsyncUserWebAuthAgent.authFlow(parameter: input as! AsyncUserWebAuthAgent.Parameter)
        return response
    }
}
