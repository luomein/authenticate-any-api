//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/21.
//

import Foundation

public protocol TokenRefreshable: Equatable{
    var refresh_token : String? {get}
}
public protocol AAAFlow: Equatable{
    associatedtype OpenAPIClientRequest : Equatable
    associatedtype OpenAPIResponse : TokenRefreshable
    var needUserWebAuth : Bool {get}
    var canRefreshToken : Bool {get}
    func requestToken(authorizedCode: String?)->OpenAPIClientRequest
    func refreshToken(refreshToken: String?)->OpenAPIClientRequest
    static func fetchRequest(clientRequest: OpenAPIClientRequest)async throws->OpenAPIResponse
    func userWebAuthParameter(prefersEphemeralWebBrowserSession: Bool) ->  AsyncUserWebAuthAgent.Parameter?
}
