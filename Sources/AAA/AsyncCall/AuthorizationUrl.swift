//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/14.
//

import Foundation
import AuthenticationServices

public class AuthorizationUrl: NSObject, ASWebAuthenticationPresentationContextProviding {
    public struct Parameter: Equatable{
        public let url: URL
        public let redirect_uri: URL
        public let prefersEphemeralWebBrowserSession:Bool
        public let response_type: String
        public init(url: URL, redirect_uri: URL, prefersEphemeralWebBrowserSession: Bool, response_type: String) {
            self.url = url
            self.redirect_uri = redirect_uri
            self.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
            self.response_type = response_type
        }
    }
    public override init() {}
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    public func popupWebLogin(url: URL, callbackURLScheme: String, prefersEphemeralWebBrowserSession: Bool,
                 completion: @escaping (Result<URL, Error>) -> Void){
        let authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { (url, error) in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                completion(.success(url))
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else{
                return
            }
            authSession.presentationContextProvider = self
            authSession.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
            authSession.start()
        }
    }
    public func asyncPopupWebLogin(url: URL, callbackURLScheme: String, prefersEphemeralWebBrowserSession: Bool) async throws -> URL{
        return try await withCheckedThrowingContinuation {continuation in
            popupWebLogin(url: url, callbackURLScheme: callbackURLScheme, prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession) { result in
                switch result {
                case .success(let url):
                    continuation.resume(returning: url)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
