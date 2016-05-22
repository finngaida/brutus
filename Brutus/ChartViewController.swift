//
//  ChartViewController.swift
//  Brutus
//
//  Created by Finn Gaida on 21.05.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import Cocoa

class ChartViewController: NSViewController {
    
    var frequencies = Array<Int>(count: Crypt.abc().count, repeatedValue: 0)
    var bars = Array<NSView>()
    var text:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.title = "Häufigkeitsverteilung"
        
        let padding:CGFloat = 20
        let gap:CGFloat = 2
        let w = (self.view.frame.width - padding * 2) / CGFloat(Crypt.abc().count) - gap * 2
        
        for (i, char) in Crypt.abc().enumerate() {
            
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
            
            let foo = NSTextView(frame: CGRectMake(bar.frame.origin.x - gap, 5, w + 2 * gap, w))
            foo.insertText(char, replacementRange: NSMakeRange(0, 1))
            foo.editable = false
            foo.selectable = false
            foo.backgroundColor = NSColor.clearColor()
            self.view.addSubview(foo)
            
            if i == Crypt.abc().count - 1 {
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
        
        for t in text.characters {
            guard let i = Crypt.abc().indexOf(String(t)) else { print("couldn't locate \(String(t))"); break }
            guard frequencies.count >= i else { print("frequencies array too short for \(String(t))"); break }
            guard bars.count >= i else { print("bars array too short for \(String(t))"); break }
            
            frequencies[i] += 1
            
            self.bars[i].animator().frame = CGRectMake(self.bars[i].frame.origin.x, self.bars[i].frame.origin.y, self.bars[i].frame.width, self.bars[i].frame.height + 1)
        }
    }
    
}
