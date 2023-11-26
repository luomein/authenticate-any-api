//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/18.
//

import Foundation

public extension String {

    public func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    public func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}
