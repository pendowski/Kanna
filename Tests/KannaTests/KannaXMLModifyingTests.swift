/**@file KannaXMLModifyingTests.swift

 Kanna

 @Copyright (c) 2015 Atsushi Kiwaki (@_tid_)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
import XCTest
import Foundation
import CoreFoundation
@testable import Kanna

class KannaXMLModifyingTests: XCTestCase {
    func testXML_MovingNode() {
        let xml = "<?xml version=\"1.0\"?><all_item><item><title>item0</title></item><item><title>item1</title></item></all_item>"
        let modifyPrevXML = "<all_item><item><title>item1</title></item><item><title>item0</title></item></all_item>"
        let modifyNextXML = "<all_item><item><title>item1</title></item><item><title>item0</title></item></all_item>"

        do {
            guard let doc = try? XML(xml: xml, encoding: .utf8) else {
                return
            }
            let item0 = doc.css("item")[0]
            let item1 = doc.css("item")[1]
            item0.addPrevSibling(item1)
            XCTAssert(doc.at_css("all_item")!.toXML == modifyPrevXML)
        }

        do {
            guard let doc = try? XML(xml: xml, encoding: .utf8) else {
                return
            }
            let item0 = doc.css("item")[0]
            let item1 = doc.css("item")[1]
            item1.addNextSibling(item0)
            XCTAssert(doc.at_css("all_item")!.toXML == modifyNextXML)
        }
    }
    
    func testXML_InsertChild() {
        let xml = "<?xml version=\"1.0\"?><all_item><item><title>item0</title></item><item><title>item1</title></item></all_item>"
        let item = "<?xml version=\"1.0\"?><item>added</item>"
        
        // Inserts into correct place
        do {
            guard let doc = try? XML(xml: xml, encoding: .utf8), let element = try? XML(xml: item, encoding: .utf8) else {
                XCTFail()
                return
            }
            
            let elementNode = element.at_css("item")
            let parent = doc.at_css("all_item")
            parent?.insertChild(elementNode!, at: 1)

            let items = doc.css("item")
            XCTAssertEqual(items.count, 3)
            XCTAssertEqual(items[1].content, "added")
            XCTAssertEqual(items[0].content, "item0")
            XCTAssertEqual(items[2].content, "item1")
        }
        
        // Inserts node as first
        do {
            guard let doc = try? XML(xml: xml, encoding: .utf8), let element = try? XML(xml: item, encoding: .utf8) else {
                XCTFail()
                return
            }
            
            let elementNode = element.at_css("item")
            let parent = doc.at_css("all_item")
            parent?.insertChild(elementNode!, at: 0)
            
            let items = doc.css("item")
            XCTAssertEqual(items.count, 3)
            XCTAssertEqual(items[0].content, "added")
            XCTAssertEqual(items[1].content, "item0")
            XCTAssertEqual(items[2].content, "item1")
        }
        
        // Adds child node at the end of the list `at` if higher then number of nodes
        do {
            guard let doc = try? XML(xml: xml, encoding: .utf8), let element = try? XML(xml: item, encoding: .utf8) else {
                XCTFail()
                return
            }
            
            let elementNode = element.at_css("item")
            let parent = doc.at_css("all_item")
            parent?.insertChild(elementNode!, at: 100)
            
            let items = doc.css("item")
            XCTAssertEqual(items.count, 3)
            XCTAssertEqual(items[2].content, "added")
            XCTAssertEqual(items[0].content, "item0")
            XCTAssertEqual(items[1].content, "item1")
        }
    }
}

extension KannaXMLModifyingTests {
    static var allTests: [(String, (KannaXMLModifyingTests) -> () throws -> Void)] {
        return [
            ("testXML_MovingNode", testXML_MovingNode),
            ("testXML_InsertChild", testXML_InsertChild)
        ]
    }
}
