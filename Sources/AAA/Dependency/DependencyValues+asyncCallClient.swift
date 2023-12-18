//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation
import ComposableArchitecture

public struct AsyncCallClient{
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
extension AsyncCallClient:DependencyKey{
    public static let liveValue: AsyncCallClient = Self(fetch: {_ in
        XCTFail("Unimplemented")
    })
}
extension DependencyValues{
    public var asyncCallClient: AsyncCallClient{
        get { self[AsyncCallClient.self] }
        set { self[AsyncCallClient.self] = newValue }
    }
}
