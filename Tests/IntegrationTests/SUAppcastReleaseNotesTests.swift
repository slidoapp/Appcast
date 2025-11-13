//
// Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
@testable import Appcast

class SUAppcastReleaseNotesTests: XCTestCase {
    func testLocalizedReleaseNotesEnglishLater() {
        let testFile = Bundle.module.path(forResource: "testlocalizedreleasenotesappcast",
                                                            ofType: "xml")!
        let testFileUrl = URL(fileURLWithPath: testFile)
        XCTAssertNotNil(testFileUrl)
        
        let preferredLanguage = Bundle.preferredLocalizations(from: ["en", "es"])[0]
        
        NSLog("Using preferred locale %@", preferredLanguage)
        
        let expectedReleaseNotesLink = (preferredLanguage == "es") ? "https://sparkle-project.org/notes.es.html" : "https://sparkle-project.org/notes.en.html"

        do {
            let testFileData = try Data(contentsOf: testFileUrl)
            
            let stateResolver = SPUAppcastItemStateResolver(hostVersion: "1.0", applicationVersionComparator: SUStandardVersionComparator.default, standardVersionComparator: SUStandardVersionComparator.default)
            
            let fullAppcast = try SUAppcast(xmlData: testFileData, relativeTo: testFileUrl, stateResolver: stateResolver)
            
            do {
                let appcast = SUAppcastDriver.filterAppcast(fullAppcast, forMacOSAndAllowedChannels: ["english-later"])
                let items = appcast.items
                XCTAssertEqual(items.count, 1)
                XCTAssertEqual(items[0].versionString, "6.0")
                XCTAssertEqual(expectedReleaseNotesLink, items[0].releaseNotesURL!.absoluteString)
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testLocalizedReleaseNotesEnglishFirst() {
        let testFile = Bundle.module.path(forResource: "testlocalizedreleasenotesappcast",
                                                            ofType: "xml")!
        let testFileUrl = URL(fileURLWithPath: testFile)
        XCTAssertNotNil(testFileUrl)
        
        let preferredLanguage = Bundle.preferredLocalizations(from: ["en", "es"])[0]
        
        NSLog("Using preferred locale %@", preferredLanguage)
        
        let expectedReleaseNotesLink = (preferredLanguage == "es") ? "https://sparkle-project.org/notes.es.html" : "https://sparkle-project.org/notes.en.html"

        do {
            let testFileData = try Data(contentsOf: testFileUrl)
            
            let stateResolver = SPUAppcastItemStateResolver(hostVersion: "1.0", applicationVersionComparator: SUStandardVersionComparator.default, standardVersionComparator: SUStandardVersionComparator.default)
            
            let fullAppcast = try SUAppcast(xmlData: testFileData, relativeTo: testFileUrl, stateResolver: stateResolver)
            
            do {
                let appcast = SUAppcastDriver.filterAppcast(fullAppcast, forMacOSAndAllowedChannels: ["english-first"])
                let items = appcast.items
                XCTAssertEqual(items.count, 1)
                XCTAssertEqual(items[0].versionString, "6.1")
                XCTAssertEqual(expectedReleaseNotesLink, items[0].releaseNotesURL!.absoluteString)
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testLocalizedReleaseNotesEnglishFirstImplicit() {
        let testFile = Bundle.module.path(forResource: "testlocalizedreleasenotesappcast",
                                                            ofType: "xml")!
        let testFileUrl = URL(fileURLWithPath: testFile)
        XCTAssertNotNil(testFileUrl)
        
        let preferredLanguage = Bundle.preferredLocalizations(from: ["en", "es"])[0]
        
        NSLog("Using preferred locale %@", preferredLanguage)
        
        let expectedReleaseNotesLink = (preferredLanguage == "es") ? "https://sparkle-project.org/notes.es.html" : "https://sparkle-project.org/notes.en.html"

        do {
            let testFileData = try Data(contentsOf: testFileUrl)
            
            let stateResolver = SPUAppcastItemStateResolver(hostVersion: "1.0", applicationVersionComparator: SUStandardVersionComparator.default, standardVersionComparator: SUStandardVersionComparator.default)
            
            let fullAppcast = try SUAppcast(xmlData: testFileData, relativeTo: testFileUrl, stateResolver: stateResolver)
            
            do {
                let appcast = SUAppcastDriver.filterAppcast(fullAppcast, forMacOSAndAllowedChannels: ["english-first-implicit"])
                let items = appcast.items
                XCTAssertEqual(items.count, 1)
                XCTAssertEqual(items[0].versionString, "6.2")
                XCTAssertEqual(expectedReleaseNotesLink, items[0].releaseNotesURL!.absoluteString)
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
    
    func testLocalizedReleaseNotesEnglishLaterImplicit() {
        let testFile = Bundle.module.path(forResource: "testlocalizedreleasenotesappcast",
                                                            ofType: "xml")!
        let testFileUrl = URL(fileURLWithPath: testFile)
        XCTAssertNotNil(testFileUrl)
        
        let preferredLanguage = Bundle.preferredLocalizations(from: ["en", "es"])[0]
        
        NSLog("Using preferred locale %@", preferredLanguage)
        
        let expectedReleaseNotesLink = (preferredLanguage == "es") ? "https://sparkle-project.org/notes.es.html" : "https://sparkle-project.org/notes.en.html"

        do {
            let testFileData = try Data(contentsOf: testFileUrl)
            
            let stateResolver = SPUAppcastItemStateResolver(hostVersion: "1.0", applicationVersionComparator: SUStandardVersionComparator.default, standardVersionComparator: SUStandardVersionComparator.default)
            
            let fullAppcast = try SUAppcast(xmlData: testFileData, relativeTo: testFileUrl, stateResolver: stateResolver)
            
            do {
                let appcast = SUAppcastDriver.filterAppcast(fullAppcast, forMacOSAndAllowedChannels: ["english-later-implicit"])
                let items = appcast.items
                XCTAssertEqual(items.count, 1)
                XCTAssertEqual(items[0].versionString, "6.3")
                XCTAssertEqual(expectedReleaseNotesLink, items[0].releaseNotesURL!.absoluteString)
            }
        } catch let err as NSError {
            NSLog("%@", err)
            XCTFail(err.localizedDescription)
        }
    }
}
