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
    public typealias AsyncRequestReducer = BaseAsyncRequestReducer<T,T.Response>
    var fetchOpenAPIClient : AsyncRequestClient
    
    public init(fetchOpenAPIClient: AsyncRequestClient = .init(fetch: Self.fetchOpenAPI(input:))
    ) {
        self.fetchOpenAPIClient = fetchOpenAPIClient
    }
    public struct State:Equatable{
        public var response: T.Response?
        public var joinStateAsyncRequestReducer : AsyncRequestReducer.State
        public init(debounceDuration : DispatchQueue.SchedulerTimeType.Stride) {
            self.joinStateAsyncRequestReducer = .init(debounceDuration: debounceDuration)
        }
    }
    public enum Action:Equatable{
        case joinActionAsyncRequestReducer(AsyncRequestReducer.Action)
        case request(T)
        case receive(T.Response)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinStateAsyncRequestReducer, action: /Action.joinActionAsyncRequestReducer) {
            BaseAsyncRequestReducer()
                .dependency(\.asyncRequestClient, fetchOpenAPIClient)
        }
        Reduce { state, action in
            switch action{
            case .request(let request):
                return .send(.joinActionAsyncRequestReducer(.debounceQueuedRequest(request: request)) )
            case .joinActionAsyncRequestReducer(let subAction):
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
