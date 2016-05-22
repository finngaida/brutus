//
//  Crypt.swift
//  Brutus
//
//  Created by Finn Gaida on 22.05.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import Foundation

public class Crypt: NSObject {
    
    public enum E:ErrorType {
        case ConversionError, UnicodeConversion, NoKeysArray, CharacterUnknown(s:Character), Unknown
    }
    
    public static func abc() -> Array<String> { return ["a", "ä", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "ö", "p", "q", "r", "s", "ß", "t", "u", "ü", "v", "w", "x", "y", "z", "A", "Ä", "B", "C", "D", "E",  "F",  "G",  "H",  "I",  "J",  "K",  "L",  "M",  "N",  "O", "Ö",  "P",  "Q",  "R",  "S",  "T",  "U", "Ü",  "V",  "W",  "X",  "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " ", ".", ",", "-", "?", "!", "\n"] }
    
    public class func caesarCrypt(s:String, key:String, encrypt:Bool, ascii: Bool, verbose: Bool) throws -> String {
        
        var uKeys:[Int]?
        var result = String()
        
        func c2I(c:Character) throws -> Int {
            if ascii {
                guard let f = String(c).unicodeScalars.first else { throw E.UnicodeConversion }
                return Int(f.value)
            } else if let i = Crypt.abc().indexOf(String(c)) {
                return i
            } else {
                throw E.CharacterUnknown(s: c)
            }
        }
        
        func i2S(i:Int) -> String? {
            if ascii {
                return String(UnicodeScalar(i))
            } else if Int(i) < 0 {
                return Crypt.abc()[Crypt.abc().count - (abs(Int(i)) % Crypt.abc().count)]
            } else if Crypt.abc().count > Int(i) {
                return Crypt.abc()[Int(i)]
            } else if Crypt.abc().count <= Int(i) {
                return Crypt.abc()[Int(i) % Crypt.abc().count]
            } else {
                return nil
            }
        }
        
        do {
            uKeys = try key.characters.map { (char) -> Int in
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
                
                if verbose {
                    let en = encrypt ? "en" : "de"
                    print("\(en)crypting \(c): code \(cCode), key \(key), new code \(encCode), new string \(encS)")
                }
                
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
