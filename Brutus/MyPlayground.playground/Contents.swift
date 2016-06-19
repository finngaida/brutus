//: Playground - noun: a place where people can play

import Foundation

public func caesarCrypt(s:String, key:Int, encrypt:Bool, ascii: Bool, verbose: Bool) throws -> String {
    
    // Hier wird jedes Zeichen einzeln angehängt
    var result = String()
    
    for char in s.characters {
        
        do {
            // 1. Zeichen in Int umwandeln
            let cCode = try s2I(String(char), ascii: ascii)
            
            // 2. Je nachdem ob ver- oder entschlüsselt wird den Schlüssel addieren/subtrahieren
            let encCode = encrypt ? cCode + key : cCode - key
            
            // 3. Wieder in einen String umwandeln
            guard let encS = i2S(encCode, ascii: ascii) else { throw E.ConversionError(i: encCode) }
            
            // 4. An das Ergebnis anhängen
            result += encS
            
        } catch let e as E {
            // Fehlermanagement
            throw e
        }
    }
    
    // Das Ergebnis zurückgeben
    return result
}


public func frequencies(s:String) -> Dictionary<String,Double> {
    
    // 1. Das Ausgabe-Dict erstellen
    var ret = Dictionary<String,Double>()
    
    s.characters.forEach { (c) in
        let d = String(c).lowercaseString
        
        // 2. Für jedes Zeichen im Text gucken, ob es schonmal vorkam
        if let f = ret[d] {
            // Wenn ja, Wert um 1 erhöhen
            ret[d] = f + 1
        } else {
            // Wenn nicht, Wert auf 1 setzen
            ret[d] = 1
        }
    }
    
    // Nun das Dict von absoluten Werten auf relative ändern
    ret.forEach { (t) in
        ret[t.0] = Double(t.1) / Double(s.characters.count)
    }
    
    // Fertig
    return ret
}


public func caesarCrack(s:String, ascii:Bool, verbose:Bool) throws -> [(String, String)] {
    
    // 1. Die Normalwahrscheinlichkeit und input-Wahrscheinlichkeit sortieren
    let sortedFrequencies = Crypt.frequencies(s).sort { $0.1 > $1.1 }
    let sortedNormality = internalNormality().sort { $0.1 > $1.1 }
    
    do {
        // 2. Jeweils die 2 häufigsten Zeichen in Int konvertieren
        let freqC1 = try s2I(sortedFrequencies[0].0, ascii: ascii)
        let normC1 = try s2I(sortedNormality[0].0, ascii: ascii)
        let freqC2 = try s2I(sortedFrequencies[1].0, ascii: ascii)
        let normC2 = try s2I(sortedNormality[1].0, ascii: ascii)
        
        // 3. Die 4 möglichen Schlüssel
        let key1 = freqC1 - normC1
        let key2 = freqC1 - normC2
        let key3 = freqC2 - normC1
        let key4 = freqC2 - normC2
        
        return try [key1, key2, key3, key4].map({ (key) -> (String, String) in
            
            // 4. Schlüssel wieder in String umwandeln
            guard let k = i2S(key, ascii: ascii) else { throw E.UnicodeConversion(i: key) }
            
            // 5. Den Text entschlüsseln und zurückgeben
            return (k, try Crypt.caesarCrypt(s, key: k, encrypt: false, ascii: ascii, verbose: verbose))
        })
    } catch let e {
        // Fehlermanagement
        throw e
    }
}



public enum E:ErrorType {
    case ConversionError(i: Any), UnicodeConversion(i: Any), NoKeysArray, CharacterUnknown(s:String), CouldntCrack(reason: String), Unknown
}

/**
 Full german alphabet with uppercase, lowercase, umlaut, numbers and signs
 
 - returns: the array
 */
public func abc() -> Array<String> { return [
    "a", "ä", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "ö", "p", "q", "r", "s", "ß", "t", "u", "ü", "v", "w",
    "x", "y", "z", "A", "Ä", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "Ö", "P", "Q", "R", "S",
    "T", "U", "Ü", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " ", ".", ",", ":", "-", "?", "!", "#", "(", ")", "<", ">", "[", "]", "%", "/", "*", "+", "=", "×", "\t", "\n", "φ", "→", "_", "\"", "\'", "₁", "₂", "₃", "^"] }

/**
 Shorter version of `.abc()` with just lowercase chars, umlaute and signs
 
 - returns: the array
 */
public func shortAbc() -> Array<String> { return ["a", "ä", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "ö", "p", "q", "r", "s", "ß", "t", "u", "ü", "v", "w", "x", "y", "z", " ", ".", ",", "-", "?", "!"] }

// Source: [SttMedia](http://www.sttmedia.de/buchstabenhaeufigkeit-deutsch)
/**
 A dictionary giving every lowercase character a percentage of frequency measures per 1000 words
 
 - returns: the dict
 */
public func normality() -> Dictionary<String,Double> { return ["a":5.58, "ä":0.54, "b":1.96, "c":3.16, "d":4.98, "e":16.93, "f":1.49, "g":3.02, "h":4.98, "i":8.02, "j":0.24, "k":1.32, "l":3.6, "m":2.55, "n":10.53, "o":2.24, "ö":0.3, "p":0.67, "q":0.02, "r":6.89, "s":6.42, "ß":0.37, "t":5.79, "u":3.83, "ü":0.65, "v":0.84, "w":1.78, "x":0.05, "y":0.05, "z":1.21] }

/**
 Converts a given string into its integer counterpart. Opposite of `i2S()`
 
 - parameter s:     The input string (one character only)
 - parameter ascii: Use Swift's built-in UnicodeScalar or the internal alphabet array `.abc()`
 
 - throws: An error of type `E` containing the failing string
 
 - returns: the int value
 */
public  func s2I(s:String, ascii:Bool) throws -> Int {
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
public  func i2S(i:Int, ascii:Bool) -> String? {
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

public static func internalNormality() -> Dictionary<String,Double> {
    return Crypt.frequencies("Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich zieht?Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen Mühen und Schmerz ihm große Freude bereiten")
}
