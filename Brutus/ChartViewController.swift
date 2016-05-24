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
    let padding:CGFloat = 20
    let gap:CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.title = "Häufigkeitsverteilung"
        
        let w = (self.view.frame.width - padding * 2) / CGFloat(Crypt.shortAbc().count) - gap * 2
        
        for (i, char) in Crypt.shortAbc().enumerate() {
            
            let gapping = gap * CGFloat(2 * i + 1)
            let x = padding + w * CGFloat(i) + gapping
            
            let oldBar = NSView(frame: CGRectMake(x, padding + w, w, 5))
            oldBar.wantsLayer = true
            oldBar.layer?.masksToBounds = true
            oldBar.layer?.cornerRadius = w / 2
            oldBar.layer?.backgroundColor = NSColor(calibratedRed: 0.141, green: 0.420, blue: 0.380, alpha: 1.00).CGColor
            oldBar.alphaValue = 1.0
            oldBars.append(oldBar)
            self.view.addSubview(oldBar)
            
            let bar = NSView(frame: CGRectMake(x, padding + w, w, 5))
            bar.wantsLayer = true
            bar.layer?.masksToBounds = true
            bar.layer?.cornerRadius = w / 2
            bar.layer?.backgroundColor = NSColor(calibratedRed: 0.631, green: 0.212, blue: 0.275, alpha: 1.00).CGColor
            bar.alphaValue = 0.8
            bars.append(bar)
            self.view.addSubview(bar)
            
            let foo = NSTextView(frame: CGRectMake(bar.frame.origin.x, 5, w + 2 * gap, w))
            foo.insertText(char, replacementRange: NSMakeRange(0, 1))
            foo.editable = false
            foo.selectable = false
            foo.backgroundColor = NSColor.clearColor()
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
            alert.addButtonWithTitle("Okay")
            alert.runModal()
            dismissController(self)
            return
        }
        
        let frequency = Crypt.frequencies(text)
        let intern = Crypt.internalNormality()
        let max = CGFloat(frequency.values.maxElement() ?? 1.0)
        do {
            let crypt = try Crypt.caesarCrack(text, accuracy: 2, ascii: false, verbose: false)
            let keys = crypt.reduce("") { $0 + ", " + $1.0 }
            
            label = NSTextView(frame: CGRectMake(self.view.frame.width / 2 - 100, self.view.frame.height - 150, 200, 50))
            label?.insertText("Key: \(keys)", replacementRange: NSMakeRange(0, 1))
            label?.font = NSFont.systemFontOfSize(30)
            label?.editable = false
            label?.selectable = false
            label?.backgroundColor = NSColor.clearColor()
            self.view.addSubview(label!)
            
            for (i, t) in Crypt.shortAbc().enumerate() {
                guard bars.count >= i && oldBars.count >= i else { print("bars array too short for \(t)"); break }
                
                if let freq = frequency[t] {
                    let b = self.bars[i]
                    let h = (self.view.frame.height - b.frame.origin.y - padding) * CGFloat(freq) / max
                    
                    b.animator().frame = CGRectMake(b.frame.origin.x, b.frame.origin.y, b.frame.width, h)
                    
                } else {
                    // print("can't get frequency for \(t) in round \(i)") 
                }
                
                if let freq = intern[t] {
                    let b = self.oldBars[i]
                    let h = (self.view.frame.height - b.frame.origin.y - padding) * CGFloat(freq) / max
                    b.animator().frame = CGRectMake(b.frame.origin.x, b.frame.origin.y, b.frame.width, h)
                    
                } else {
                    // print("can't get frequency for \(t) in round \(i)")
                }
            }
            
            for (i, enText) in crypt.enumerate() {
                
                // let the user create a file to save to
                let dialog = NSSavePanel()
                dialog.title = "Erstelle eine Datei zum Sichern"
                dialog.showsResizeIndicator = true
                dialog.showsHiddenFiles = false
                dialog.canCreateDirectories = true
                dialog.nameFieldStringValue = "Entschlüsselt-Option-\(i+1)"
                dialog.allowedFileTypes = ["txt"]
                
                if (dialog.runModal() == NSModalResponseOK) {
                    if let result = dialog.URL, path = result.path {
                        NSFileManager.defaultManager().createFileAtPath(path, contents: enText.1.dataUsingEncoding(NSUTF8StringEncoding), attributes: [:])
                    } else {
                        print("an error occured unwrapping \(dialog)")
                        let alert = NSAlert()
                        alert.messageText = "Das hat leider nicht funktioniert."
                        alert.addButtonWithTitle("Okay")
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
