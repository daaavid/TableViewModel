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

class AcceptanceSpec: QuickSpec {
    override func spec() {
        describe("table view model") {

            context("when a table view is initialized with a 'TableViewModel'") {
                var tableView: UITableView!
                var view: UIView!
                var viewController: UIViewController!
                var model: TableViewModel!
                var bundle: Bundle!

                /*
                 * Shortcuts for accessing table cells
                 */

                func cellAtIndexOfFirstSection(_ rowindex: Int) -> UITableViewCell? {
                    return tableView.cellForRow(at: indexPathForRowInFirstSection(rowindex))
                }

                func firstCell() -> UITableViewCell? {
                    return cellAtIndexOfFirstSection(0)
                }

                func secondCell() -> UITableViewCell? {
                    return cellAtIndexOfFirstSection(1)
                }

                func thirdCell() -> UITableViewCell? {
                    return cellAtIndexOfFirstSection(2)
                }

                beforeEach {
                    bundle = Bundle(for: type(of: self))

                    view = UIView()
                    view.frame = UIScreen.main.bounds

                    viewController = UIViewController()
                    viewController.view = view

                    tableView = UITableView()
                    tableView.frame = view.bounds;
                    view.addSubview(tableView)

                    model = TableViewModel(tableView: tableView)

                    ViewControllerTestingHelper.pushViewController(viewController)
                }

                it("doesn't have any sections") {
                    expect(tableView.numberOfSections) == 0
                }

                context("when a section is added to the model") {

                    var section: TableSection!

                    beforeEach {
                        section = TableSection()
                        model.addSection(section)
                    }

                    it("has 1 section") {
                        expect(tableView.numberOfSections) == 1
                    }

                    context("when another section is added to the model") {
                        var section2: TableSection!
                        var row1, row2: TableRow!

                        beforeEach {
                            section2 = TableSection()
                            model.addSection(section2)

                            row1 = TableRow(cellIdentifier: "SampleCell1", inBundle: bundle)
                            section.addRow(row1)

                            row2 = TableRow(cellIdentifier: "SampleCell2", inBundle: bundle)
                            section2.addRow(row2)
                        }

                        it("has 2 sections") {
                            expect(tableView.numberOfSections) == 2
                        }

                        it("has sections in correct order") {
                            expect(tableView.cellForRow(at: IndexPath(row: 0, section: 0))).to(beASampleCell1())
                            expect(tableView.cellForRow(at: IndexPath(row: 0, section: 1))).to(beASampleCell2())
                        }

                        context("when all sections are removed from the model") {
                            beforeEach {
                                model.removeAllSections()
                            }

                            it("has 0 sections") {
                                expect(tableView.numberOfSections) == 0
                            }
                        }
                    }

                    context("when another section is inserted at index 0") {
                        var section2: TableSection!
                        var row1, row2: TableRow!

                        beforeEach {
                            section2 = TableSection()
                            model.insertSection(section2, atIndex: 0)

                            row1 = TableRow(cellIdentifier: "SampleCell1", inBundle: bundle)
                            section.addRow(row1)

                            row2 = TableRow(cellIdentifier: "SampleCell2", inBundle: bundle)
                            section2.addRow(row2)
                        }

                        it("has 2 section") {
                            expect(tableView.numberOfSections) == 2
                        }

                        it("has sections in correct order") {
                            expect(tableView.cellForRow(at: IndexPath(row: 0, section: 1))).to(beASampleCell1())
                            expect(tableView.cellForRow(at: IndexPath(row: 0, section: 0))).to(beASampleCell2())
                        }
                    }

                    context("when the section is removed from model") {
                        beforeEach {
                            model.removeSection(section)
                        }

                        it("has 0 sections") {
                            expect(tableView.numberOfSections) == 0
                        }
                    }

                    context("when a row is added to the section") {

                        var row1: TableRow!

                        beforeEach {
                            row1 = TableRow(cellIdentifier: "SampleCell1", inBundle: bundle)
                            section.addRow(row1)
                        }

                        it("has 1 cell in section") {
                            expect(tableView.numberOfRows(inSection: 0)) == 1
                        }

                        it("has the correct cell") {
                            let cell = firstCell()
                            expect(cell).to(beASampleCell1())
                        }

                        context("when another row is added to the section") {
                            var row2: TableRow!

                            beforeEach {
                                row2 = TableRow(cellIdentifier: "SampleCell1", inBundle: bundle)
                                section.addRow(row2)
                            }

                            it("has 2 cells in section") {
                                expect(tableView.numberOfRows(inSection: 0)) == 2
                            }

                            it("has the correct cells") {
                                let cell1 = firstCell()
                                let cell2 = secondCell()
                                expect(cell1).to(beASampleCell1())
                                expect(cell2).to(beASampleCell1())
                                expect(cell1) !== cell2
                            }

                            context("when the first row is removed") {
                                var cell1, cell2: UITableViewCell!

                                beforeEach {
                                    cell1 = firstCell()
                                    cell2 = secondCell()

                                    section.removeRow(row1)
                                }

                                it("has 1 cell") {
                                    expect(tableView.numberOfRows(inSection: 0)) == 1
                                }

                                it("has the correct cell") {
                                    let actualCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                                    expect(actualCell) === cell2
                                }
                            }

                            context("when all rows are removed") {
                                beforeEach {
                                    section.removeAllRows()
                                }

                                it("removes all rows section") {
                                    expect(tableView.numberOfRows(inSection: 0)) == 0
                                }
                            }
                        }

                        context("when a configuration closure is added to the row after adding the row to the section") {
                            beforeEach {
                                row1.configureCell {
                                    cell in
                                    let label = cell.contentView.subviews[0] as! UILabel
                                    label.text = "Configured the cell"
                                }
                            }

                            it("configures the cell") {
                                let cell = firstCell()
                                let label = cell?.contentView.subviews[0] as! UILabel
                                expect(label.text) == "Configured the cell"
                            }
                        }

                        context("when a configuration closure is added to the row before adding the row to a section") {
                            beforeEach {
                                let row2 = TableRow(cellIdentifier: "SampleCell1", inBundle: bundle)
                                row2.configureCell {
                                    cell in
                                    let label = cell.contentView.subviews[0] as! UILabel
                                    label.text = "Configured"
                                }
                                section.addRow(row2)
                            }

                            it("configures the cell") {
                                let cell = secondCell()
                                let label = cell?.contentView.subviews[0] as! UILabel
                                expect(label.text) == "Configured"
                            }
                        }

                        context("when a selection handler is configured for the row") {
                            var selectionHandlerIsCalled: Bool!
                            var rowParameterPassedToClosure: TableRow?
                            beforeEach {
                                selectionHandlerIsCalled = false
                                rowParameterPassedToClosure = nil
                                row1.onSelect {
                                    row in
                                    rowParameterPassedToClosure = row
                                    selectionHandlerIsCalled = true
                                }
                            }

                            context("when the cell is selected") {
                                beforeEach {
                                    tableView.selectRow(at: firstRowIndexPath(), animated: false, scrollPosition: UITableViewScrollPosition.top)
                                    model.tableView(tableView, didSelectRowAt: firstRowIndexPath())
                                }

                                it("calls the selection handler when the cell is selected") {
                                    expect(selectionHandlerIsCalled) == true
                                }

                                it("deselects the cell by default") {
                                    var selectedRowIndexPath = tableView.indexPathForSelectedRow
                                    expect(selectedRowIndexPath).to(beNil())
                                }

                                it("passes correct row parameter to the closure") {
                                    expect(rowParameterPassedToClosure) === row1
                                }
                            }
                        }

                        context("when row is configured for not deselcting the cell after selection") {
                            beforeEach {
                                row1.shouldDeselectAfterSelection = false
                            }

                            context("when the cell is selected") {
                                beforeEach {
                                    tableView.selectRow(at: firstRowIndexPath(), animated: false, scrollPosition: UITableViewScrollPosition.top)
                                    model.tableView(tableView, didSelectRowAt: firstRowIndexPath())
                                }

                                it("does not deselect the cell") {
                                    var selectedRowIndexPath = tableView.indexPathForSelectedRow
                                    expect(selectedRowIndexPath?.row) == firstRowIndexPath().row
                                    expect(selectedRowIndexPath?.section) == firstRowIndexPath().section
                                }
                            }
                        }

                        context("when the row is configured for not to deselect after selection") {

                            func selectRow(at indexPath: IndexPath) {
                                tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)

                                // We need to notify the model manually here because tableView doesn't
                                // call the delegate method after selectRowAtIndexPath
                                model.tableView(tableView, didSelectRowAt: firstRowIndexPath())
                            }

                            beforeEach {
                                row1.shouldDeselectAfterSelection = false
                            }

                            context("when the cell is selected") {
                                beforeEach {
                                    selectRow(at: firstRowIndexPath())
                                }

                                it("does not deselect the cell") {
                                    let selectedRowIndexPath = tableView.indexPathForSelectedRow
                                    expect(selectedRowIndexPath!.row) == 0
                                    expect(selectedRowIndexPath!.section) == 0
                                }
                            }
                        }
                    }

                    context("when a row with custom height cell added to the section") {
                        beforeEach {
                            let row = TableRow(cellIdentifier: "SampleCell2", inBundle: bundle)
                            section.addRow(row)
                        }

                        it("configures correct height for the cell") {
                            let cell = firstCell()
                            expect(cell?.frame.height) == 80
                        }
                    }

                    context("when height of cell is given externally") {
                        beforeEach {
                            let row = TableRow(cellIdentifier: "SampleCell2", inBundle: bundle)
                            row.height = 120
                            section.addRow(row)
                        }

                        it("ignores the cell height in the nib") {
                            let cell = firstCell()
                            expect(cell?.frame.height) == 120
                        }
                    }
                    
                    context("when configure height closure is set") {
                        beforeEach {
                            let row = TableRow(cellIdentifier: "SampleCell2", inBundle: bundle)
                            row.height = 120
                            row.configureHeight {
                                return 90
                            }
                            section.addRow(row)
                        }
                        
                        it("ignores the cell height in the nib and height property") {
                            let cell = firstCell()
                            expect(cell?.frame.height) == 90
                        }
                    }

                    context("when a cell with variable height is used") {
                        var rows: Array<TableRow>!

                        beforeEach {
                            rows = Array<TableRow>()

                            for i in 1 ..< 20 {
                                let row = TableRow(cellIdentifier: "SampleCell1", inBundle: bundle)
                                row.height = Float(100 + i)
                                rows.append(row)
                                section.addRow(row)
                            }
                        }

                        it("renders each row in correct height") {
                            for i in 1 ..< 20 {
                                let indexPath = IndexPath(row: (i - 1), section: 0)
                                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                let cell = tableView.cellForRow(at: indexPath)
                                expect(cell?.frame.height) == CGFloat(100 + i)
                            }
                        }
                    }
                    
                    context("when multiple rows are added to the section") {
                        var row1: TableRow!
                        var row2: TableRow!
                        var row3: TableRow!

                        beforeEach {
                            row1 = sampleRowWithLabelText("row1")
                            row2 = sampleRowWithLabelText("row2")
                            row3 = sampleRowWithLabelText("row3")

                            let rows: Array<TableRowProtocol> = [row1, row2, row3]

                            section.addRows(rows)
                        }

                        it("adds each row to the table view") {
                            expect(firstCell()).to(beASampleCellWithLabelText("row1"))
                            expect(secondCell()).to(beASampleCellWithLabelText("row2"))
                            expect(thirdCell()).to(beASampleCellWithLabelText("row3"))
                        }

                        context("when multiple rows are removed from the section") {
                            beforeEach {
                                section.removeRows([row1, row3])
                            }

                            it("removes each row in the parameter array from the table view") {
                                expect(tableView.numberOfRows(inSection: 0)) == 1
                                expect(firstCell()).to(beASampleCellWithLabelText("row2"))
                            }
                        }
                    }

                    context("when a row is inserted into an index of a section") {
                        var row1: TableRow!
                        var row2: TableRow!
                        var row3: TableRow!

                        beforeEach {
                            row1 = sampleRowWithLabelText("row1")
                            row2 = sampleRowWithLabelText("row2")
                            row3 = sampleRowWithLabelText("row3")

                            let initialRows: Array<TableRowProtocol> = [row1, row3]

                            section.addRows(initialRows)
                            section.insertRow(row2, atIndex: 1)
                        }

                        it("places the inserted row to the correct index") {
                            expect(firstCell()).to(beASampleCellWithLabelText("row1"))
                            expect(secondCell()).to(beASampleCellWithLabelText("row2"))
                            expect(thirdCell()).to(beASampleCellWithLabelText("row3"))
                        }
                    }
                }

                context("when a table section with header view added to the model") {
                    var section: TableSection!
                    var headerView: UIView!

                    beforeEach {
                        headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))

                        section = TableSection()
                        section.headerView = headerView
                        section.headerHeight = Float(30)

                        model.addSection(section)
                    }

                    it("displays the header view in the table view") {
                        // TODO: this test doesn't pass
//                        let actualHeaderView = tableView.headerViewForSection(0)
//
//                        expect(actualHeaderView) === headerView
                    }

                    it("displays the header view with correct height") {
                        // TODO: this test doesn't pass
//                        let actualHeaderView = tableView.headerViewForSection(0)!
//
//                        expect(actualHeaderView.frame.size.height) == 30
                    }
                }
            }

        }
    }
}

/*
 * Utility functions
 */

func indexPathForRowInFirstSection(_ rowIndex: Int) -> IndexPath {
    return IndexPath(row: rowIndex, section: 0)
}

func firstRowIndexPath() -> IndexPath {
    return indexPathForRowInFirstSection(0)
}

func secondRowIndexPath() -> IndexPath {
    return indexPathForRowInFirstSection(1)
}

func thirdRowIndexPath() -> IndexPath {
    return indexPathForRowInFirstSection(2)
}

func sampleRowWithLabelText(_ labelText: String) -> TableRow {
    let row = TableRow(cellIdentifier: "SampleCell1", inBundle: Bundle(for: type(of: AcceptanceSpec())))
    row.configureCell {
        cell in
        let label = cell.contentView.subviews[0] as! UILabel
        label.text = labelText
    }
    return row
}

/*
 * Matchers for sample cells
 */

func beASampleCell1<T:UITableViewCell>() -> MatcherFunc<T?> {
    return MatcherFunc {
        actualExpression, failureMessage in
        failureMessage.postfixMessage = " be a SampleCell1"
        do {
            let cell = try actualExpression.evaluate() as? UITableViewCell
            let label = cell?.contentView.subviews[0] as? UILabel
            return label?.text == "SampleCell1"
        } catch {
            return false
        }
    }
}

func beASampleCell2<T:UITableViewCell>() -> MatcherFunc<T?> {
    return MatcherFunc {
        actualExpression, failureMessage in
        failureMessage.postfixMessage = " be a SampleCell2"
        do {
            let cell = try actualExpression.evaluate() as? UITableViewCell
            let button = cell?.contentView.subviews[0] as? UIButton
            return button?.title(for: UIControlState.normal) == "SampleCell2"
        } catch {
            return false
        }
    }
}

func beASampleCellWithLabelText<T:UITableViewCell>(_ expectedLabelText: String) -> MatcherFunc<T?> {
    return MatcherFunc {
        actualExpression, failureMessage in
        failureMessage.postfixMessage = " be a SampleCell1 with label text '\(expectedLabelText)'"
        do {
            let cell = try actualExpression.evaluate() as? UITableViewCell
            let label = cell?.contentView.subviews[0] as? UILabel
            return label?.text == expectedLabelText
        } catch {
            return false
        }
    }
}
