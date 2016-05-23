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
            let bar = NSView(frame: CGRectMake(x, padding + w, w, 5))
            bar.wantsLayer = true
            bar.layer?.masksToBounds = true
            bar.layer?.cornerRadius = w / 2
            bar.layer?.backgroundColor = NSColor(calibratedRed: 0.631, green: 0.212, blue: 0.275, alpha: 1.00).CGColor
            //            bar.tag = i
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
        let max = CGFloat(frequency.values.maxElement() ?? 1.0)
        _ = try? Crypt.caesarCrack(text, accuracy: 3, ascii: false, verbose: false)
        
        for (i, t) in Crypt.shortAbc().enumerate() {
            guard bars.count >= i else { print("bars array too short for \(t)"); break }
            
            if let freq = frequency[t] {
                let b = self.bars[i]
                let h = (self.view.frame.height - b.frame.origin.y - padding) * CGFloat(freq) / max
                print("the frequency for \(t) is \(freq) with bar \(h)")
                
                b.animator().frame = CGRectMake(b.frame.origin.x, b.frame.origin.y, b.frame.width, h)
                
            } else { print("can't get frequency for \(t) in round \(i)") }
        }
    }
    
}
