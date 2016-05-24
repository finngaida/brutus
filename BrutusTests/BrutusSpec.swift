//
//  BrutusTests.swift
//  BrutusTests
//
//  Created by Finn Gaida on 20.05.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import Brutus

class BrutusSpec: QuickSpec {
    
    override func spec() {
        
        context("BrutusSpecs.swift") {
            
            describe("check the hardcoded alphabet arrays of the `abc`, `shortAbc` and `narmality` functions") {
                
                it("should contain 26 letters + 3 umlaute (x2 because Uppercase) + 10 numbers + .,- !? (6)") {
                    
                    expect(Crypt.abc().count).to(equal((26 + 3) * 2 + 10 + 6))
                    
                }
                
                it("should contain 26 letters + 3 umlaute + .,-!? (5)") {
                    
                    expect(Crypt.shortAbc().count).to(equal(26 + 3 + 5))
                    
                }
                
            }
            
        }
        
    }
    
}
