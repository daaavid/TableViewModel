/*

Copyright (c) 2016 Tunca Bergmen <tunca@bergmen.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

import Foundation
import UIKit
import Quick
import Nimble

import TableViewModel

class TableRowSpec: QuickSpec {
    override func spec() {
        describe("TableRow") {
            var bundle: Bundle!
            var tableRow: TableRow!
            var tableView: UITableView!

            beforeEach {
                bundle = Bundle(for: type(of: self))
                tableView = UITableView()
                tableRow = TableRow(cellIdentifier: "SampleCell1", inBundle: bundle)
            }

            context("when asked for the cell") {
                var cell: UITableViewCell!

                beforeEach {
                    cell = tableRow.cellForTableView(tableView)
                }

                it("returns the correct cell") {
                    let label = cell!.contentView.subviews[0] as! UILabel
                    expect(label.text) == "SampleCell1"
                }

                it("registers the cell as a reusable cell in the table view") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SampleCell1")
                    expect(cell).toNot(beNil())
                }
            }

            // TODO: test always fails because dequeueReusableCellWithIdentifier
            // returns a different instance every time
//            context("when the cell is already registered as a reusable cell") {
//                beforeEach {
//                    let nib: UINib = UINib(nibName: "SampleCell1", bundle: bundle)
//                    tableView.registerNib(nib, forCellReuseIdentifier: "SampleCell1")
//                }
//
//                context("when asked for the cell") {
//                    var cell: UITableViewCell!
//
//                    beforeEach {
//                        cell = tableRow.cellForTableView(tableView)
//                    }
//
//                    it("dequeues the reusable cell") {
//                        var dequeued = tableView.dequeueReusableCellWithIdentifier("SampleCell1")
//                        expect(cell) === dequeued
//                    }
//                }
//            }
        }
    }
}
