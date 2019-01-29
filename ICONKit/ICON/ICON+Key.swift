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

typealias KeyPair = (pub: PublicKey, prv: PrivateKey)

open class Key {
    private var key: Data
    
    public var hexEncoded: String {
        return self.key.hexEncodedString()
    }
    
    public var data: Data {
        return key
    }
    
    public init(hexData: Data) {
        self.key = hexData
    }
}

open class PublicKey: Key {
    public var base64Encoded: String {
        return self.data.base64EncodedString()
    }
}

open class PrivateKey: Key {
    
}
