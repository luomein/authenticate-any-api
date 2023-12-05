//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/26.
//

import Foundation
import AAA

///
///
///
///
public enum AAAGitHub: Equatable{
    case github_app_user_access_token_webflow(client_id: String, client_secret: String, redirect_uri: URL) //https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-user-access-token-for-a-github-app
    
    case oauth_app_user_access_token_webflow(client_id: String, client_secret: String, redirect_uri: URL, scope: [Scope]?) //https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps

}
