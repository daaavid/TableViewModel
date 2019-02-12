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

/**
    The object that represents a section in a table view.
*/
@objcMembers open class TableSection: NSObject {

    internal fileprivate(set) var rows: NSMutableArray

    /**
        The table view that this section is bound to.
    
        - Warning: This property will be set internally when the section is added to a TableViewModel. Do not try to set this manually.
    */
    open internal(set) var tableView: UITableView?
    
    /**
     The table view model that this section belongs to.
        
     - Warning: This property will be set internally when the section is added to a TableViewModel. Do not try to set this manually.
    */
    open internal(set) weak var tableViewModel: TableViewModel?

    /// The row animation that will be displayed when rows are inserted or removed.
    open var rowAnimation: UITableViewRowAnimation

    /// A UIView instance that will be displayed as the header view of the section.
    open var headerView: UIView?
    
    /// Height of the header view.
    open var headerHeight: Float = 0
    
    /**
        Header title of the section.
     
        - Remark: When this property is set without setting the header height, it will set the header height to 30.

        - Warning: If the headerView property is set, this title will not be shown.
     */
    open var headerTitle: String? = nil {
        didSet {
            if headerHeight == 0 {
                headerHeight = Float(30)
            }
        }
    }

    /**
        Initializes the TableSection.
    */
    public init(rowAnimation: UITableViewRowAnimation = UITableViewRowAnimation.fade) {
        rows = NSMutableArray()
        self.rowAnimation = rowAnimation

        super.init()

        addObserver(self, forKeyPath: "rows", options: NSKeyValueObservingOptions.new, context: nil)
    }

    deinit {
        removeObserver(self, forKeyPath: "rows")
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey:Any]?, context: UnsafeMutableRawPointer?) {
        guard let indexSet: IndexSet = change?[NSKeyValueChangeKey.indexesKey] as? IndexSet else {
            return
        }

        guard let tableViewModel = self.tableViewModel else {
            return
        }

        guard let kind: NSKeyValueChange = NSKeyValueChange(rawValue: change?[NSKeyValueChangeKey.kindKey] as! UInt) else {
            return
        }

        guard let tableView = self.tableView else {
            return
        }

        let sectionIndex = tableViewModel.indexOfSection(self)

        var indexPaths = Array<IndexPath>()
        for idx in indexSet {
            let indexPath: IndexPath = IndexPath(row: idx, section: sectionIndex)
            indexPaths.append(indexPath)
        }

        tableView.beginUpdates()
        switch kind {
        case .insertion:
            tableView.insertRows(at: indexPaths, with: rowAnimation)
        case .removal:
            tableView.deleteRows(at: indexPaths, with: rowAnimation)
        default:
            return
        }
        tableView.endUpdates()
    }

    /**
        Adds a row to the section.

        - Parameters:
            - row: The row to be added.
    */
    open func addRow(_ row: TableRowProtocol) {
        assignTableSectionOfRow(row)
        observableRows().add(row)
    }

    /**
        Adds multiple rows to the section.
     
        - Parameters:
            - rowsToAdd: Array of rows to be added.
     
        - Remark: Use this method instead of adding rows one by one in a loop. It performs remarkably better.
    */
    open func addRows(_ rowsToAdd: Array<TableRowProtocol>) {
        rowsToAdd.forEach(assignTableSectionOfRow)
        let rowObjects = rowsToAdd.map {
            row in
            return row as AnyObject
        }
        let rowsProxy = self.observableRows()
        let range = NSMakeRange(self.rows.count, rowObjects.count)
        let indexes = IndexSet(integersIn: range.toRange() ?? 0..<0)
        rowsProxy.insert(rowObjects, at: indexes)
    }

    /**
        Inserts a row at the given index.
     
        - Parameters:
            - row: The row to be added.
            - atIndex: Index at which the row will be added.
     */
    open func insertRow(_ row: TableRowProtocol, atIndex index: Int) {
        assignTableSectionOfRow(row)
        observableRows().insert(row, at: index)
    }

    /**
        Removes a row from the section.
     
        - Parameters:
            - row: The row to be removed.
    */
    open func removeRow(_ row: TableRowProtocol) {
        removeTableSectionOfRow(row)
        observableRows().remove(row)
    }

    /**
        Removes multiple rows.
     
        - Parameters:
            - rowsToRemove: Array of rows that will be removed.

        - Remark: Use this method instead of removing rows one by one in a loop. It performs remarkably better.
    */
    open func removeRows(_ rowsToRemove: Array<TableRowProtocol>) {
        rowsToRemove.forEach(removeTableSectionOfRow)
        let rowsProxy = self.observableRows()
        let indexes = NSMutableIndexSet()
        for row in rowsToRemove {
            let index = self.indexOfRow(row)
            indexes.add(index)
        }
        rowsProxy.removeObjects(at: indexes as IndexSet)
    }

    /**
        Removes all rows from the section.

        - Remark: Use this method instead of adding rows one by one in a loop. It performs remarkably better.
    */
    open func removeAllRows() {
        let allRows = self.rows.map {
            row in
            return row as! TableRowProtocol
        }
        allRows.forEach(removeTableSectionOfRow)
        let rowsProxy = self.observableRows()
        let range = NSMakeRange(0, rowsProxy.count)
        let indexes = IndexSet(integersIn: range.toRange() ?? 0..<0)
        rowsProxy.removeObjects(at: indexes)
    }

    // Returns number of rows in the section.
    open func numberOfRows() -> Int {
        return rows.count
    }

    /// Returns the row object at given index.
    open func rowAtIndex(_ index: Int) -> TableRowProtocol {
        return rows.object(at: index) as! TableRowProtocol
    }

    /// Returns the index of row object.
    open func indexOfRow(_ row: TableRowProtocol) -> Int {
        return rows.index(of: row)
    }

    fileprivate func assignTableSectionOfRow(_ row: TableRowProtocol) {
        row.tableSection = self
    }

    fileprivate func removeTableSectionOfRow(_ row: TableRowProtocol) {
        guard self.indexOfRow(row) != NSNotFound else {
            return
        }
        row.tableSection = nil
    }

    fileprivate func observableRows() -> NSMutableArray {
        return mutableArrayValue(forKey: "rows")
    }

    /**
        Returns an immutable NSArray object contains all rows added to the section.
     
        - Warning: Do not try to modify this array, use add, insert and remove methods instead.
    */
    open func allRows() -> NSArray {
        return rows
    }
}
