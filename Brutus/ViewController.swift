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
    @IBOutlet weak var useAscii: NSButton!
    @IBOutlet weak var useVerbose: NSButton!
    @IBOutlet weak var useShortAlphabet: NSButton!
    
    var file:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default().addObserver(forName: NSNotification.Name.NSControlTextDidChange, object: nil, queue: OperationQueue.current()) { (notif) in
            if self.keyField.stringValue == "" {
                self.decryptButton.title = "Cracken"
            } else {
                self.decryptButton.title = "Entschlüsseln"
            }
        }
    }
    
    @IBAction func chooseFile(_ sender: NSButton) {
        
        let dialog = NSOpenPanel()
        dialog.title = "Wähle eine .txt Datei"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["txt"]
        
        if (dialog.runModal() == NSModalResponseOK) {
            if let result = dialog.url, path = result.path {
                do {
                    openFileButton.title = result.lastPathComponent ?? "Datei öffnen"
                    file = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                    encryptButton.isEnabled = true
                    decryptButton.isEnabled = true
                } catch let e as NSError {
                    print("an error occurred: \(e.description)")
                    NSAlert(error: e).runModal()
                }
            }
        } else {
            return
        }
    }
    
    @IBAction func encrypt(_ sender: NSButton) {
        if keyField.stringValue.characters.count > 0, let f = file {
            do {
                let encryptedString = try Crypt.caesarCrypt(f, key: keyField.stringValue, encrypt: true, ascii: Bool(useAscii.state), verbose: Bool(useVerbose.state))
                
                // let the user create a file to save to
                let dialog = NSSavePanel()
                dialog.title = "Erstelle eine Datei zum Sichern"
                dialog.showsResizeIndicator = true
                dialog.showsHiddenFiles = false
                dialog.canCreateDirectories = true
                dialog.nameFieldStringValue = "Verschlüsselt"
                dialog.allowedFileTypes = ["txt"]
                
                if (dialog.runModal() == NSModalResponseOK) {
                    if let result = dialog.url, path = result.path {
                        FileManager.default().createFile(atPath: path, contents: encryptedString.data(using: String.Encoding.utf8), attributes: [:])
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
                
            } catch let e {
                print("an error occured: \(e)")
                let alert = NSAlert()
                alert.messageText = "Das hat leider nicht funktioniert. Grund: \n \(e)"
                alert.addButton(withTitle: "Okay")
                alert.runModal()
            }
        } else {
            let alert = NSAlert()
            alert.messageText = "Bitte einen Schlüssel eingeben"
            alert.addButton(withTitle: "Okay")
            alert.runModal()
        }
    }
    
    @IBAction func decrypt(_ sender: NSButton) {
        if keyField.stringValue.characters.count > 0, let f = file {
            do {
                let decryptedString = try Crypt.caesarCrypt(f, key: keyField.stringValue, encrypt: false, ascii: Bool(useAscii.state), verbose: Bool(useVerbose.state))
                
                // let the user create a file to save to
                let dialog = NSSavePanel()
                dialog.title = "Erstelle eine Datei zum Sichern"
                dialog.showsResizeIndicator = true
                dialog.showsHiddenFiles = false
                dialog.canCreateDirectories = true
                dialog.nameFieldStringValue = "Entschlüsselt"
                dialog.allowedFileTypes = ["txt"]
                
                if (dialog.runModal() == NSModalResponseOK) {
                    if let result = dialog.url, path = result.path {
                        FileManager.default().createFile(atPath: path, contents: decryptedString.data(using: String.Encoding.utf8), attributes: [:])
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
                
            } catch let e {
                print("an error occured: \(e)")
                let alert = NSAlert()
                alert.messageText = "Das hat leider nicht funktioniert. Grund: \n \(e)"
                alert.addButton(withTitle: "Okay")
                alert.runModal()
            }
        } else {
            self.performSegue(withIdentifier: "showChart", sender: self)
        }
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChart", let dest = segue.destinationController as? ChartViewController {
            dest.text = file
            dest.ascii = Bool(self.useAscii.state)
            dest.verbose = Bool(self.useVerbose.state)
        }
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

