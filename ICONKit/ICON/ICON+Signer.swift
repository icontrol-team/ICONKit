/*
 * Copyright 2018 ICON Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import Foundation
import CryptoSwift

protocol TransactionSigner: SECP256k1 {
    
}

extension TransactionSigner where Self: Transaction {
    private func serialize() throws -> (Data, [String: Any]) {
        var dic = [String: Any]()
        guard let from = self.from,
            let to = self.to,
            let nid = self.nid,
            let nonce = self.nonce,
            let stepLimit = self.stepLimit else {
                throw ICError.invalid(.transaction)
        }
        dic["version"] = self.version
        dic["timestamp"] = self.timestamp
        dic["from"] = from
        dic["to"] = to
        dic["nid"] = nid
        dic["nonce"] = nonce
        dic["stepLimit"] = "0x" + String(stepLimit, radix: 16)
        if let value = self.value {
            let hexValue = "0x" + String(value, radix: 16)
            dic["value"] = hexValue
        }
        if let dataType = self.dataType {
            if let data = self.data {
                dic["data"] = data
            }
            dic["dataType"] = dataType
        }
        
        guard let data = ("icx_sendTransaction." + serialize(dic)).data(using: .utf8) else {
            throw ICError.convert(.data)
        }
        print("data = \(String(data: data, encoding: .utf8))")
        return (data, dic)
    }
    
    private func serialize(_ object: Any) -> String {
        var serial = ""
        if let dic = object as? [String: Any] {
            serial += serializeDictionary(dic)
        } else if let arr = object as? [Any] {
            serial += serializeArray(arr)
        } else {
            serial += ".\(object)"
        }
        return serial
    }
    
    private func serializeDictionary(_ dictionary: [String: Any]) -> String {
        let keys = dictionary.keys.sorted()
        var serial = ""
        for key in keys {
            if serial != "" { serial += "." }
            if let value = dictionary[key] as? [String: Any] {
                serial += "\(key).{" + serializeDictionary(value) + "}"
            } else if let value = dictionary[key] as? [Any] {
                serial += "\(key).[" + serializeArray(value) + "]"
            } else if let value = dictionary[key] as? String {
                serial += "\(key).\(value)"
            }
        }
        return serial
    }
    
    private func serializeArray(_ array: [Any]) -> String {
        var serial = ""
        for item in array {
            if serial != "" { serial += "." }
            serial += "\(item)"
        }
        return serial
    }
    
    func signTransaction(privateKey: String) throws -> (String, [String: Any]) {
        let v = try self.serialize()
        let serialized = v.0

        let hashed = serialized.sha3(.sha256)
        
        let signed = try signECDSA(hashedMessage: hashed, privateKey: privateKey)
        var params = v.1
        params["signature"] = signed.base64EncodedString()
        return (signed.base64EncodedString(), params)
    }
    
    func getTxHash() throws -> String {
        let v = try self.serialize()
        let serialized = v.0
        
        let hashed = serialized.sha3(.sha256)
        
        return hashed.toHexString()
    }
}
