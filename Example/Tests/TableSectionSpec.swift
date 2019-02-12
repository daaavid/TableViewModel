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

class TableSectionSpec: QuickSpec {
    override func spec() {
        describe("TableSection") {
            var section: TableSection!

            beforeEach {
                section = TableSection()
            }

            it("has a default header heigth 0") {
                expect(section.headerHeight) == 0
            }

            context("when a row is added to the section") {
                var row: TableRow!

                beforeEach {
                    row = TableRow(cellIdentifier: "", inBundle: Bundle(for: type(of: self)))
                    section.addRow(row)
                }

                it("sets the tableSection property in the row") {
                    expect(row.tableSection) === section
                }

                context("when the row is removed from the section") {
                    beforeEach {
                        section.removeRow(row)
                    }

                    it("sets the tableSection property of the row to nil") {
                        expect(row.tableSection).to(beNil())
                    }
                }

                context("when all rows are removed from the section") {
                    beforeEach {
                        section.removeAllRows()
                    }

                    it("sets the tableSection property of the row to nil") {
                        expect(row.tableSection).to(beNil())
                    }
                }
            }

            context("when removeRow is called with a row that wasn't added to the section") {
                var sectionOfRow: TableSection!
                var row: TableRow!

                beforeEach {
                    sectionOfRow = TableSection()
                    row = TableRow(cellIdentifier: "")
                    sectionOfRow.addRow(row)

                    section.removeRow(row)
                }

                it("doesn't change tableSection property value of the row") {
                    expect(row.tableSection) === sectionOfRow
                }
            }

            context("when multiple rows are added to the section") {
                var row1: TableRow!
                var row2: TableRow!

                beforeEach {
                    row1 = TableRow(cellIdentifier: "")
                    row2 = TableRow(cellIdentifier: "")

                    section.addRows([row1, row2])
                }

                it("sets the tableSection property of each row") {
                    expect(row1.tableSection) === section
                    expect(row2.tableSection) === section
                }

                context("when multiple rows are removed from the section") {
                    beforeEach {
                        section.removeRows([row1, row2])
                    }

                    it("sets the table section of each row to nil") {
                        expect(row1.tableSection).to(beNil())
                        expect(row2.tableSection).to(beNil())
                    }
                }
            }

            context("when a row is inserted to the section") {
                var row1: TableRow!
                var row2: TableRow!

                beforeEach {
                    row1 = TableRow(cellIdentifier: "")
                    row2 = TableRow(cellIdentifier: "")

                    section.addRow(row2)
                    section.insertRow(row1, atIndex: 0)
                }

                it("sets the tableSection property of the inserted row") {
                    expect(row1.tableSection) === section
                }
            }

            context("when a header title is set") {
                beforeEach {
                    section.headerTitle = "Test title"
                }

                it("updates the header height to a default 30 pt") {
                    expect(section.headerHeight) == 30
                }
            }

            context("when header height is set manually") {
                beforeEach {
                    section.headerHeight = Float(48)
                }

                context("when a header title is set") {
                    beforeEach {
                        section.headerTitle = "Test title"
                    }

                    it("does not change the manually set header height") {
                        expect(section.headerHeight) == 48
                    }
                }
            }
        }
    }
}
