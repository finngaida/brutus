//
//  Crypt.swift
//  Brutus
//
//  Created by Finn Gaida on 22.05.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import Foundation

public class Crypt: NSObject {
    
    /**
     The error type commonly thrown by Brutus
     
     - ConversionError:   An int couldn't be converted into a character
     - UnicodeConversion: A character couldn't be converted into an int
     - NoKeysArray:       An optional keys array couldn't be unwrapped
     - CharacterUnknown:  The character has no integer counterpart
     - CouldntCrack:      A valid key for the given text couldn't be found
     - Unknown:           No idea what happened
     */
    public enum E:ErrorType {
        case ConversionError(i: Any), UnicodeConversion(i: Any), NoKeysArray, CharacterUnknown(s:String), CouldntCrack(reason: String), Unknown
    }
    
    /**
     Full german alphabet with uppercase, lowercase, umlaut, numbers and signs
     
     - returns: the array
     */
    public static func abc() -> Array<String> { return [
        "a", "ä", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "ö", "p", "q", "r", "s", "ß", "t", "u", "ü", "v", "w",
        "x", "y", "z", "A", "Ä", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "Ö", "P", "Q", "R", "S",
        "T", "U", "Ü", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " ", ".", ",", ":", "-", "?", "!", "#", "(", ")", "<", ">", "[", "]", "%", "/", "*", "+", "=", "×", "\t", "\n", "φ", "→", "_", "\"", "\'", "₁", "₂", "₃", "^"] }
    
    /**
     Shorter version of `.abc()` with just lowercase chars, umlaute and signs
     
     - returns: the array
     */
    public static func shortAbc() -> Array<String> { return ["a", "ä", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "ö", "p", "q", "r", "s", "ß", "t", "u", "ü", "v", "w", "x", "y", "z", " ", ".", ",", "-", "?", "!"] }
    
    // Source: [SttMedia](http://www.sttmedia.de/buchstabenhaeufigkeit-deutsch)
    /**
     A dictionary giving every lowercase character a percentage of frequency measures per 1000 words
     
     - returns: the dict
     */
    public static func normality() -> Dictionary<String,Double> { return ["a":5.58, "ä":0.54, "b":1.96, "c":3.16, "d":4.98, "e":16.93, "f":1.49, "g":3.02, "h":4.98, "i":8.02, "j":0.24, "k":1.32, "l":3.6, "m":2.55, "n":10.53, "o":2.24, "ö":0.3, "p":0.67, "q":0.02, "r":6.89, "s":6.42, "ß":0.37, "t":5.79, "u":3.83, "ü":0.65, "v":0.84, "w":1.78, "x":0.05, "y":0.05, "z":1.21] }
    
    /**
     Converts a given string into its integer counterpart. Opposite of `i2S()`
     
     - parameter s:     The input string (one character only)
     - parameter ascii: Use Swift's built-in UnicodeScalar or the internal alphabet array `.abc()`
     
     - throws: An error of type `E` containing the failing string
     
     - returns: the int value
     */
    public class func s2I(s:String, ascii:Bool) throws -> Int {
        if ascii {
            guard let f = s.unicodeScalars.first else { throw E.UnicodeConversion(i: s) }
            return Int(f.value)
        } else if let i = Crypt.abc().indexOf(s) {
            return i
        } else {
            throw E.CharacterUnknown(s: s)
        }
    }
    
    /**
     Converts a given integer into its string counterpart. Opposte of `s2I()`
     
     - parameter i:     The input integer
     - parameter ascii: Use Swift's built-in UnicodeScalar or the internal alphabet array `.abc()`
     
     - returns: The string value
     */
    public class func i2S(i:Int, ascii:Bool) -> String? {
        if ascii {
            return String(UnicodeScalar(abs(i)))        // TODO: wrap around instead of abs
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
    
    /**
     Calculates the relative frequencies of every character in the input text
     
     - parameter s: The text to be analyzed
     
     - returns: A dictionary containing perone amounts of how often the key appears in `s`
     */
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
    
    /**
     En-/decrypt a text using the Caesar chiffre. To do that first the input text gets converted into numbers who are all shifted forward the number value of the key (the x. char of the key) to encrypt and shifted backwards to decrypt.
     
     - parameter s:       The input text to be en-/decrypted
     - parameter key:     The key to crypt (one char for Caesar, >1 chars for Viginère)
     - parameter encrypt: Bool flag to know which way to crypt
     - parameter ascii:   Use Swift's built-in UnicodeScalar or the internal alphabet array `.abc()`
     - parameter verbose: Print error and success messages to the console
     
     - throws: An error of type `E` containing the failing character
     
     - returns: The en-/decrypted string
     */
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
                
                guard let encS = i2S(encCode, ascii: ascii) else { throw E.ConversionError(i: encCode) }
                result += encS
                
                if verbose {
                    let en = encrypt ? "en" : "de"
                    print("\(en)crypting \(c): code \(cCode), key \(key), new code \(encCode), new string \(encS)")
                }
                
            } catch let e as E {
                throw e
            }
        }
        
        if result.characters.count != s.characters.count && verbose {
            print("the output char count does not match the input file")
        }
        
        return result
    }
    
    /**
     Attempts to crack a given caesar encrypted string by analyzing the frequency of the signs and comparing it to the default frequency of signs in a german text.
     
     - parameter s:        The encrypted text
     - parameter accuracy: Number of characteristics to check (the higher the more possible outcomes, but also the higher the propability of having a correct key)
     - parameter ascii:    Use Swift's UnicodeScalar when true and an internal string to int array when false
     - parameter verbose:  Show more log output
     
     - throws: Error of type `E` describing the failure
     
     - returns: An array of possible (key, decrypted text) pairs
     */
    public class func caesarCrack(s:String, accuracy:Int, ascii:Bool, verbose:Bool) throws -> [(String, String)] {
        
        let sortedFrequencies = Crypt.frequencies(s).sort { $0.1 > $1.1 }
        let sortedNormality = internalNormality().sort { $0.1 > $1.1 }
        
        var last = 0
        var keys = Array<String>()
        for (_, iTuple) in sortedFrequencies[0..<accuracy].enumerate() {
            for (_, jTuple) in sortedNormality[0..<accuracy].enumerate() {
                do {
                    let freqC = try s2I(iTuple.0, ascii: ascii)
                    let normC = try s2I(jTuple.0, ascii: ascii)
                    
                    if freqC - normC != last || last == 0 {
                        last = freqC - normC
                        
                        guard let key = i2S(last, ascii: ascii) else {
                            if verbose {
                                print("the int key is \(last), but has no alphanumeric counterpart")
                            }
                            throw E.UnicodeConversion(i: last)
                        }
                        
                        keys.append(key)
                    } else  {
                        throw E.CouldntCrack(reason: "Found too many different keys")
                    }
                    
                    if verbose {
                        print("offset: \(last) freq \(freqC) \(iTuple.0) norm \(normC) \(jTuple.0)")
                    }
                } catch let e as E {
                    print("couldn't convert string to int: \(e) ascii: \(ascii)")
                }
            }
        }
        
        do {
            return try keys.map({ (key) -> (String, String) in
                do {
                    return (key, try Crypt.caesarCrypt(s, key: key, encrypt: false, ascii: ascii, verbose: verbose))
                } catch let e as E {
                    throw e
                }
            })
        } catch let e {
            throw e
        }
    }
    
    /**
     Returns a dictionary of relative frequencies of lowercase characters on a hardcoded sample text in german.
     
     - returns: the dictionary
     */
    public static func internalNormality() -> Dictionary<String,Double> {
        return Crypt.frequencies("Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht?Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten")
    }
    
}
