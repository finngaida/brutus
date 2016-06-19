//
//  ChartViewController.swift
//  Brutus
//
//  Created by Finn Gaida on 21.05.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import Cocoa

class ChartViewController: NSViewController {
    
    var bars = Array<NSView>()
    var oldBars = Array<NSView>()
    var label:NSTextView?
    var text:String?
    var verbose:Bool = false
    var ascii:Bool = false
    let padding:CGFloat = 20
    let gap:CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.title = "Häufigkeitsverteilung"
        
        let w = (self.view.frame.width - padding * 2) / CGFloat(Crypt.shortAbc().count) - gap * 2
        
        for (i, char) in Crypt.shortAbc().enumerated() {
            
            let gapping = gap * CGFloat(2 * i + 1)
            let x = padding + w * CGFloat(i) + gapping
            
            let oldBar = NSView(frame: CGRect(x: x, y: padding + w, width: w, height: 5))
            oldBar.wantsLayer = true
            oldBar.layer?.masksToBounds = true
            oldBar.layer?.cornerRadius = w / 2
            oldBar.layer?.backgroundColor = NSColor(calibratedRed: 0.141, green: 0.420, blue: 0.380, alpha: 1.00).cgColor
            oldBar.alphaValue = 1.0
            oldBars.append(oldBar)
            self.view.addSubview(oldBar)
            
            let bar = NSView(frame: CGRect(x: x, y: padding + w, width: w, height: 5))
            bar.wantsLayer = true
            bar.layer?.masksToBounds = true
            bar.layer?.cornerRadius = w / 2
            bar.layer?.backgroundColor = NSColor(calibratedRed: 0.631, green: 0.212, blue: 0.275, alpha: 1.00).cgColor
            bar.alphaValue = 0.8
            bars.append(bar)
            self.view.addSubview(bar)
            
            let foo = NSTextView(frame: CGRect(x: bar.frame.origin.x, y: 5, width: w + 2 * gap, height: w))
            foo.insertText(char, replacementRange: NSMakeRange(0, 1))
            foo.isEditable = false
            foo.isSelectable = false
            foo.backgroundColor = NSColor.clear()
            self.view.addSubview(foo)
            
            if i == Crypt.shortAbc().count - 1 {
                self.animate()
            }
        }
    }
    
    func animate() {
        
        guard let text = text else {
            let alert = NSAlert()
            alert.messageText = "Bitte lesen sie eine valide Datei ein."
            alert.addButton(withTitle: "Okay")
            alert.runModal()
            dismiss(self)
            return
        }
        
        let frequency = Crypt.frequencies(text)
        let intern = Crypt.internalNormality()
        let max = CGFloat(frequency.values.max() ?? 1.0)
        do {
            let crypt = try Crypt.caesarCrack(text, accuracy: 2, ascii: self.ascii, verbose: self.verbose)
            let keys = crypt.reduce("") { $0 + ", " + $1.0 }
            
            label = NSTextView(frame: CGRect(x: self.view.frame.width / 2 - 100, y: self.view.frame.height - 150, width: 200, height: 50))
            label?.insertText("Key: \(keys)", replacementRange: NSMakeRange(0, 1))
            label?.font = NSFont.systemFont(ofSize: 30)
            label?.isEditable = false
            label?.isSelectable = false
            label?.backgroundColor = NSColor.clear()
            self.view.addSubview(label!)
            
            for (i, t) in Crypt.shortAbc().enumerated() {
                guard bars.count >= i && oldBars.count >= i else { print("bars array too short for \(t)"); break }
                
                if let freq = frequency[t] {
                    let b = self.bars[i]
                    let h = (self.view.frame.height - b.frame.origin.y - padding) * CGFloat(freq) / max
                    
                    b.animator().frame = CGRect(x: b.frame.origin.x, y: b.frame.origin.y, width: b.frame.width, height: h)
                    
                } else {
                    // print("can't get frequency for \(t) in round \(i)") 
                }
                
                if let freq = intern[t] {
                    let b = self.oldBars[i]
                    let h = (self.view.frame.height - b.frame.origin.y - padding) * CGFloat(freq) / max
                    b.animator().frame = CGRect(x: b.frame.origin.x, y: b.frame.origin.y, width: b.frame.width, height: h)
                    
                } else {
                    // print("can't get frequency for \(t) in round \(i)")
                }
            }
            
            for (i, enText) in crypt.enumerated() {
                
                // let the user create a file to save to
                let dialog = NSSavePanel()
                dialog.title = "Erstelle eine Datei zum Sichern"
                dialog.showsResizeIndicator = true
                dialog.showsHiddenFiles = false
                dialog.canCreateDirectories = true
                dialog.nameFieldStringValue = "Entschlüsselt-Option-\(i+1)"
                dialog.allowedFileTypes = ["txt"]
                
                if (dialog.runModal() == NSModalResponseOK) {
                    if let result = dialog.url, path = result.path {
                        FileManager.default().createFile(atPath: path, contents: enText.1.data(using: String.Encoding.utf8), attributes: [:])
                    } else {
                        print("an error occured unwrapping \(dialog)")
                        let alert = NSAlert()
                        alert.messageText = "Das hat leider nicht funktioniert."
                        alert.addButton(withTitle: "Okay")
                        alert.runModal()
                    }
                } else {
                    return
                }
            }
            
        } catch let e {
            print("there was an error: \(e)")
        }
    }
    
}
