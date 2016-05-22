//
//  ViewController.swift
//  Brutus
//
//  Created by Finn Gaida on 20.05.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var openFileButton: NSButton!
    @IBOutlet weak var encryptButton: NSButton!
    @IBOutlet weak var decryptButton: NSButton!
    @IBOutlet weak var keyField: NSTextField!
    
    var file:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func chooseFile(sender: NSButton) {
        
        let dialog = NSOpenPanel()
        dialog.title = "Wähle eine .txt Datei"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["txt"]
        
        if (dialog.runModal() == NSModalResponseOK) {
            if let result = dialog.URL, path = result.path {
                do {
                    openFileButton.title = result.lastPathComponent ?? "Datei öffnen"
                    file = try String(contentsOfFile: path)
                    encryptButton.enabled = true
                    decryptButton.enabled = true
                } catch let e as NSError {
                    print("an error occurred: \(e.description)")
                    NSAlert(error: e).runModal()
                }
            }
        } else {
            return
        }
    }
    
    @IBAction func encrypt(sender: NSButton) {
        if keyField.stringValue.characters.count > 0, let f = file {
            do {
                let encryptedString = try Crypt.caesarCrypt(f, key: keyField.stringValue, encrypt: true, ascii: false, verbose: false)
                
                // let the user create a file to save to
                let dialog = NSSavePanel()
                dialog.title = "Erstelle eine Datei zum Sichern"
                dialog.showsResizeIndicator = true
                dialog.showsHiddenFiles = false
                dialog.canCreateDirectories = true
                dialog.allowedFileTypes = ["txt"]
                
                if (dialog.runModal() == NSModalResponseOK) {
                    if let result = dialog.URL, path = result.path {
                        NSFileManager.defaultManager().createFileAtPath(path, contents: encryptedString.dataUsingEncoding(NSUTF8StringEncoding), attributes: [:])
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
                
            } catch let e {
                print("an error occured: \(e)")
                let alert = NSAlert()
                alert.messageText = "Das hat leider nicht funktioniert. Grund: \n \(e)"
                alert.addButtonWithTitle("Okay")
                alert.runModal()
            }
        } else {
            let alert = NSAlert()
            alert.messageText = "Bitte einen Schlüssel eingeben"
            alert.addButtonWithTitle("Okay")
            alert.runModal()
        }
    }
    
    @IBAction func decrypt(sender: NSButton) {
        if keyField.stringValue.characters.count > 0, let f = file {
            do {
                let decryptedString = try Crypt.caesarCrypt(f, key: keyField.stringValue, encrypt: false, ascii: false, verbose: false)
                
                // let the user create a file to save to
                let dialog = NSSavePanel()
                dialog.title = "Erstelle eine Datei zum Sichern"
                dialog.showsResizeIndicator = true
                dialog.showsHiddenFiles = false
                dialog.canCreateDirectories = true
                dialog.allowedFileTypes = ["txt"]
                
                if (dialog.runModal() == NSModalResponseOK) {
                    if let result = dialog.URL, path = result.path {
                        NSFileManager.defaultManager().createFileAtPath(path, contents: decryptedString.dataUsingEncoding(NSUTF8StringEncoding), attributes: [:])
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
                
            } catch let e {
                print("an error occured: \(e)")
                let alert = NSAlert()
                alert.messageText = "Das hat leider nicht funktioniert. Grund: \n \(e)"
                alert.addButtonWithTitle("Okay")
                alert.runModal()
            }
        } else {
            self.performSegueWithIdentifier("showChart", sender: self)
        }
    }
    
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChart", let dest = segue.destinationController as? ChartViewController {
            dest.text = file
        }
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

