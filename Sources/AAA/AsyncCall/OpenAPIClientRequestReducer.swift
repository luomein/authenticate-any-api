//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/12/3.
//

import Foundation
import ComposableArchitecture

public protocol OpenAPIClientRequestProtocol:Equatable{
    associatedtype Client
    associatedtype Request
    associatedtype Response : Equatable
    var client : Client {get}
    var request: Request {get}
    static func fetchOpenAPI(clientRequest: Self)async throws->Response
}
public struct OpenAPIClientRequestReducer<T: OpenAPIClientRequestProtocol> : Reducer{
    public typealias AsyncCallReducer = BaseAsyncCallReducer<T,T.Response>
    var asyncCallClient : AsyncCallClient
    
    public init(asyncCallClient: AsyncCallClient = .init(fetch: Self.fetchOpenAPI(input:))
    ) {
        self.asyncCallClient = asyncCallClient
    }
    public struct State:Equatable{
        public var response: T.Response?
        public var joinStateAsyncCallReducer : AsyncCallReducer.State
        public init(debounceDuration : DispatchQueue.SchedulerTimeType.Stride) {
            self.joinStateAsyncCallReducer = .init(debounceDuration: debounceDuration)
        }
    }
    public enum Action:Equatable{
        case joinActionAsyncCallReducer(AsyncCallReducer.Action)
        case asyncCall(T)
        case receive(T.Response)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinStateAsyncCallReducer, action: /Action.joinActionAsyncCallReducer) {
            AsyncCallReducer()
                .dependency(\.asyncCallClient, asyncCallClient)
        }
        Reduce { state, action in
            switch action{
            case .asyncCall(let request):
                return .send(.joinActionAsyncCallReducer(.debounceQueuedRequest(request: request)) )
            case .joinActionAsyncCallReducer(let subAction):
                switch subAction{
                case .response(.success(let response)):
                    return .send(.receive(response))
                default:
                    break
                }
            case .receive(let response):
                state.response = response
            }
            return .none
        }
    }
}
extension OpenAPIClientRequestReducer{
    public static func fetchOpenAPI(input: Sendable) async throws -> Sendable {
        let response = try await T.fetchOpenAPI(clientRequest: input as! T)
        return response
    }

}
