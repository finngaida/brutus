//
//  ChartViewController.swift
//  Brutus
//
//  Created by Finn Gaida on 21.05.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import Cocoa

class ChartViewController: NSViewController {
    
    var frequencies = Array<Int>(count: 31, repeatedValue: 0)
    var bars = Array<NSView>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.title = "Häufigkeitsverteilung"
        
        let padding = self.view.frame.width / 20
        let w = (self.view.frame.width - padding * 2) / CGFloat(Crypt.abc().count)
        
        for (i, char) in Crypt.abc().enumerate() {
            
            let bar = NSView(frame: CGRectMake(padding + w * CGFloat(i), self.view.frame.height - padding - w - 10, w, 5))
            bar.wantsLayer = true
            bar.layer?.masksToBounds = true
            bar.layer?.cornerRadius = w / 2
            bar.layer?.backgroundColor = NSColor(calibratedRed: 0.631, green: 0.212, blue: 0.275, alpha: 1.00).CGColor
            //            bar.tag = i
            bars.append(bar)
            self.view.addSubview(bar)
            
            let foo = NSTextView(frame: CGRectMake(bar.frame.origin.x, self.view.frame.height - w - 5, w, w))
            foo.insertText(char, replacementRange: NSMakeRange(0, 1))
            self.view.addSubview(foo)
        }
    }
    
    func setText(text: String?) {
        
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
            
            bars[i].frame = CGRectMake(bars[i].frame.origin.x, bars[i].frame.origin.y - 5, bars[i].frame.width, bars[i].frame.height + 5)
        }
    }
    
}
