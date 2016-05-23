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
        case ConversionError, UnicodeConversion, NoKeysArray, CharacterUnknown(s:String), CouldntCrack, Unknown
    }
    
    public static func abc() -> Array<String> { return ["a", "ä", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "ö", "p", "q", "r", "s", "ß", "t", "u", "ü", "v", "w", "x", "y", "z", "A", "Ä", "B", "C", "D", "E",  "F",  "G",  "H",  "I",  "J",  "K",  "L",  "M",  "N",  "O", "Ö",  "P",  "Q",  "R",  "S",  "T",  "U", "Ü",  "V",  "W",  "X",  "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " ", ".", ",", "-", "?", "!", "\n"] }
    
    public static func shortAbc() -> Array<String> { return ["a", "ä", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "ö", "p", "q", "r", "s", "ß", "t", "u", "ü", "v", "w", "x", "y", "z", " ", ".", ",", "-", "?", "!", "\n"] }
    
    // Source: [SttMedia](http://www.sttmedia.de/buchstabenhaeufigkeit-deutsch)
    public static func normality() -> Dictionary<String,Double> { return ["a":5.58, "ä":0.54, "b":1.96, "c":3.16, "d":4.98, "e":16.93, "f":1.49, "g":3.02, "h":4.98, "i":8.02, "j":0.24, "k":1.32, "l":3.6, "m":2.55, "n":10.53, "o":2.24, "ö":0.3, "p":0.67, "q":0.02, "r":6.89, "s":6.42, "ß":0.37, "t":5.79, "u":3.83, "ü":0.65, "v":0.84, "w":1.78, "x":0.05, "y":0.05, "z":1.21] }
    
    public class func s2I(s:String, ascii:Bool) throws -> Int {
        if ascii {
            guard let f = s.unicodeScalars.first else { throw E.UnicodeConversion }
            return Int(f.value)
        } else if let i = Crypt.abc().indexOf(s) {
            return i
        } else {
            throw E.CharacterUnknown(s: s)
        }
    }
    
    public class func i2S(i:Int, ascii:Bool) -> String? {
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
    
    public class func frequencies(s:String) -> Dictionary<String,Double> {
        var ret = Dictionary<String,Double>()
        s.characters.forEach { (c) in
            let d = String(c).lowercaseString
            if let f = ret[d] {
                ret[d] = f + 1
            } else {
                ret[d] = 1
            }
        }
        
        ret.forEach { (t) in
            ret[t.0] = Double(t.1) / Double(s.characters.count)
        }
        
        return ret
    }
    
    public class func caesarCrypt(s:String, key:String, encrypt:Bool, ascii: Bool, verbose: Bool) throws -> String {
        
        var uKeys:[Int]?
        var result = String()
        
        do {
            uKeys = try key.characters.map { (char) -> Int in
                do {
                    return try s2I(String(char), ascii: ascii)
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
                let cCode = try s2I(String(c), ascii: ascii)
                let encCode = encrypt ? cCode + key : cCode - key
                
                guard let encS = i2S(encCode, ascii: ascii) else { throw E.ConversionError }
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
    
    public class func caesarCrack(s:String, accuracy:Int, ascii:Bool, verbose:Bool) throws -> (String, String) {
        
        let sortedFrequencies = Crypt.frequencies(s).sort { $0.1 > $1.1 }
        let sortedNormality = internalNormality().sort { $0.1 > $1.1 }
        
        var last = 0
        for (i, tuple) in sortedFrequencies[0..<accuracy].enumerate() {
            do {
                let freqC = try s2I(tuple.0, ascii: ascii)
                let normC = try s2I(sortedNormality[i].0, ascii: ascii)
                
                if freqC - normC != last && last != 0 {
                    throw E.CouldntCrack
                } else {
                    last = freqC - normC
                }
                
                if verbose {
                    print("offset: \(last) freq \(freqC) \(tuple.0) norm \(normC) \(sortedNormality[i].0)")
                }
            } catch let e as E {
                print("couldn't convert string to int: \(e)")
            }
        }
        
        guard let key = i2S(last, ascii: ascii) else {
            if verbose {
                print("the int key is \(last), but has no alphanumeric counterpart")
            }
            throw E.CouldntCrack
        }
        
        do {
            return (key, try Crypt.caesarCrypt(s, key: key, encrypt: false, ascii: ascii, verbose: verbose))
        } catch let e as E {
            throw e
        }
    }
    
    public static func internalNormality() -> Dictionary<String,Double> {
        return Crypt.frequencies("Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht?Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten")
    }
    
}
