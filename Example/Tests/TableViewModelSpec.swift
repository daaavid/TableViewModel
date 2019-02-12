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

class TableViewModelSpec: QuickSpec {
    override func spec() {
        describe("TableVieWModel") {
            var tableView: UITableView!
            var tableViewModel: TableViewModel!

            beforeEach {
                tableView = UITableView()

                tableViewModel = TableViewModel(tableView: tableView)
            }

            context("when a section is added to the table view model") {
                var section: TableSection!

                beforeEach {
                    section = TableSection()
                    tableViewModel.addSection(section)
                }

                it("sets itself to the tableViewModel property of the section") {
                    expect(section.tableViewModel) === tableViewModel
                }

                it("sets its tableView to the tableView property of the section") {
                    expect(section.tableView) === tableView
                }

                context("when the section has a header view") {
                    var headerView: UIView!

                    beforeEach {
                        headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))

                        section.headerView = headerView
                        section.headerHeight = Float(30)
                        section.headerTitle = "Test Section"
                    }

                    it("returns correct header view when asked") {
                        expect(tableViewModel.tableView(tableView, viewForHeaderInSection: 0)) === headerView
                    }

                    it("returns correct header view height when asked") {
                        expect(tableViewModel.tableView(tableView, heightForHeaderInSection: 0)) == 30
                    }

                    it("returns correct title for section when asked") {
                        expect(tableViewModel.tableView(tableView, titleForHeaderInSection: 0)) == "Test Section"
                    }
                }

                context("when the added section is removed from the table view vmodel") {
                    beforeEach {
                        tableViewModel.removeSection(section)
                    }

                    it("sets the tableViewModel property of the section to nil") {
                        expect(section.tableViewModel).to(beNil())
                    }

                    it("sets the tableView property of the section to nil") {
                        expect(section.tableView).to(beNil())
                    }
                }

                context("when all sections are removed from table view model") {
                    beforeEach {
                        tableViewModel.removeAllSections()
                    }

                    it("sets the tableViewModel property of the section to nil") {
                        expect(section.tableViewModel).to(beNil())
                    }

                    it("sets the tableView property of the section to nil") {
                        expect(section.tableView).to(beNil())
                    }
                }

                context("when a section is inserted to the table view model") {
                    var insertedSection: TableSection!

                    beforeEach {
                        insertedSection = TableSection()
                        tableViewModel.insertSection(insertedSection, atIndex: 0)
                    }

                    it("sets itself to the tableViewModel property of the inserted section") {
                        expect(insertedSection.tableViewModel) === tableViewModel
                    }

                    it("sets itstableView to the tableView property of the section") {
                        expect(insertedSection.tableView) === tableView
                    }
                }

            }

            context("when removeSection is called with a section that wasn't added to the tableViewModel") {
                var section: TableSection!
                var tableViewOfSection: UITableView!
                var tableViewModelOfSection: TableViewModel!

                beforeEach {
                    section = TableSection()

                    tableViewOfSection = UITableView()
                    tableViewModelOfSection = TableViewModel(tableView: tableViewOfSection)

                    tableViewModelOfSection.addSection(section)

                    tableViewModel.removeSection(section)
                }

                it("does not change tableView and tableViewModel property values of the section") {
                    expect(section.tableView) === tableViewOfSection
                    expect(section.tableViewModel) === tableViewModelOfSection
                }
            }
        }
    }
}
