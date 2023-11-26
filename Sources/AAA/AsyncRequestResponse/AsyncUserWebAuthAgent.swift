//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/14.
//

import Foundation
import AuthenticationServices

public class AsyncUserWebAuthAgent: NSObject, ASWebAuthenticationPresentationContextProviding {
    public struct Parameter: Equatable{
        let url: URL
        let redirect_uri: URL
        let prefersEphemeralWebBrowserSession:Bool
        let response_type: String
        public init(url: URL, redirect_uri: URL, prefersEphemeralWebBrowserSession: Bool, response_type: String) {
            self.url = url
            self.redirect_uri = redirect_uri
            self.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
            self.response_type = response_type
        }
    }
    public override init() {
        
    }
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    public func userWebAuthView(url: URL, callbackURLScheme: String, prefersEphemeralWebBrowserSession: Bool,
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
    public func asyncUserWebAuthView(url: URL, callbackURLScheme: String, prefersEphemeralWebBrowserSession: Bool) async throws -> URL{
        return try await withCheckedThrowingContinuation {continuation in
            userWebAuthView(url: url, callbackURLScheme: callbackURLScheme, prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession) { result in
                switch result {
                case .success(let url):
                    continuation.resume(returning: url)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    public func parseWebAuthResponse(responseURL: URL,response_type: String )throws->String{
        
        let responseComponents = URLComponents(url: responseURL, resolvingAgainstBaseURL: false)
        return responseComponents!.queryItems!.first(where: {
            $0.name == response_type
        })!.value!
    }
    public static func authFlow(parameter: Parameter) async throws ->String{
        let agent = AsyncUserWebAuthAgent()
        let response = try await agent.asyncUserWebAuthView(url: parameter.url
                                                           , callbackURLScheme: parameter.redirect_uri.scheme!, prefersEphemeralWebBrowserSession: parameter.prefersEphemeralWebBrowserSession)
        let code =  try agent.parseWebAuthResponse(responseURL: response, response_type: parameter.response_type)
        return code
    }
}
