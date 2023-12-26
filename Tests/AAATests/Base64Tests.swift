//
//  Base64Tests.swift
//  
//
//  Created by MEI YIN LO on 2023/12/26.
//

import XCTest
import AAA

final class Base64Tests: XCTestCase {

    

    func test() throws {
        //let key = "xvz1evFS4wEEPTGEFPHBog:L8qq9PZyRg6ieKGEKhZolGC0vJWLw8iEJ88DRdyOg"
        let key = "\(Credential.TwitterAuth.consumer_api_key):\(Credential.TwitterAuth.consumer_api_secret)"
        print(key.toBase64())
        //assert(key.toBase64() == "eHZ6MWV2RlM0d0VFUFRHRUZQSEJvZzpMOHFxOVBaeVJnNmllS0dFS2hab2xHQzB2SldMdzhpRUo4OERSZHlPZw==")
        //
    }

}
