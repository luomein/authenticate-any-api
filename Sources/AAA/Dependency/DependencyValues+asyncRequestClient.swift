//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation
import ComposableArchitecture

public struct AsyncRequestClient{
    var fetch: ( Sendable) async throws ->  Sendable
    
    public static var passThroughClient = Self(fetch: {sendable in
       return sendable
    })
    public static var fetchArrayClient = Self(fetch: {sendable in
       return [sendable]
    })
    public init(fetch: @escaping ( Sendable) async throws ->  Sendable) {
        self.fetch = fetch
    }
}
extension AsyncRequestClient:DependencyKey{
    public static let liveValue: AsyncRequestClient = Self(fetch: {_ in
        XCTFail("Unimplemented")
    })
//    public static let testValue: AsyncRequestClient = passThroughClient
}
extension DependencyValues{
    public var asyncRequestClient: AsyncRequestClient{
        get { self[AsyncRequestClient.self] }
        set { self[AsyncRequestClient.self] = newValue }
    }
}
