//
//  Crypt.swift
//  Brutus
//
//  Created by Finn Gaida on 22.05.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import Foundation

class Crypt: NSObject {
    
    enum E:ErrorType {
        case ConversionError, UnicodeConversion, NoKeysArray, CharacterUnknown(s:Character), Unknown
    }
    
    static func abc() -> Array<String> { return ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E",  "F",  "G",  "H",  "I",  "J",  "K",  "L",  "M",  "N",  "O",  "P",  "Q",  "R",  "S",  "T",  "U",  "V",  "W",  "X",  "Y", "Z", " ", ".", ",", "-", "?", "!"] }
    
    class func caesarCrypt(s:String, key:String, encrypt:Bool) throws -> String {
        
        let ascii = false
        var uKeys:[UInt32]?
        var result = String()
        
        func c2I(c:Character) throws -> UInt32 {
            if ascii {
                guard let f = String(c).unicodeScalars.first else { throw E.UnicodeConversion }
                return f.value
            } else if let i = Crypt.abc().indexOf(String(c)) {
                return UInt32(i)
            } else {
                throw E.CharacterUnknown(s: c)
            }
        }
        
        func i2S(i:UInt32) -> String? {
            if ascii {
                return String(UnicodeScalar(i))
            } else if Int(i) < 0 {
                return Crypt.abc()[Crypt.abc().count - (abs(Int(i)) % Crypt.abc().count)]
            } else if Crypt.abc().count >= Int(i) {
                return Crypt.abc()[Int(i)]
            } else if Crypt.abc().count < Int(i) {
                return Crypt.abc()[Int(i) % Crypt.abc().count]
            } else {
                return nil
            }
        }
        
        do {
            uKeys = try key.characters.map { (char) -> UInt32 in
                do {
                    return try c2I(char)
                } catch let e as E {
                    throw e
                }
            }
        } catch let e as E {
            throw e
        }
        
        guard let keys = uKeys else { throw E.NoKeysArray }
        
        for (i, c) in s.characters.enumerate() {
            let key = keys[i%keys.count]
            
            do {
                let cCode = try c2I(c)
                let encCode = encrypt ? cCode + key : cCode - key
                
                guard let encS = i2S(encCode) else { throw E.ConversionError }
                result += encS
                
            } catch let e as E {
                throw e
            }
        }
        
        if result.characters.count == s.characters.count {
            return result
        } else {
            throw E.Unknown
        }
        
    }
    
}
