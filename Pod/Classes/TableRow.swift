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

/// Protocol to represent a table row. You implement this protocol to create rows that has a custom behavior. If you are not planning to add custom behavior, we encourage you to use the TableRow class instead.
public protocol TableRowProtocol: class, AnyObject {

    /// Returns the cell that this row contains.
    func cellForTableView(_ tableView: UITableView) -> UITableViewCell?

    /// Returns the height of cell.
    func heightForCell() -> CGFloat

    /// Called when the row is selected.
    func select()

    /// If set to false, the cell cannot be selected.
    var allowsSelection: Bool { get }

    /// If set to true, the cell can be edited.
    var allowsEdit: Bool { get }
    
    /// The actions which will displayed when editing a row.
    var editActions: [UITableViewRowAction]? { get }

    /// If set to true, deselects the row when it is selected.
    var shouldDeselectAfterSelection: Bool { get }

    /// Table section that this row belongs to.
    var tableSection: TableSection? { get set }
}

/// The object that represents a table row.
open class TableRow: TableRowProtocol {
    fileprivate let cellIdentifier: String
    fileprivate var bundle: Bundle?
    fileprivate var configureClosure: ((_ cell:UITableViewCell) -> ())?
    fileprivate var configureHeightClosure: (() -> Float)?
    fileprivate var onSelectionClosure: ((_ row:TableRow) -> ())?

    /// The cell instance this row contains.
    open fileprivate(set) var cell: UITableViewCell?
    
    /**
        The table section that this row belongs to.
     
        - Warning: This property will be set internally when the row is added to a TableSection. Do not try to set this manually.
    */
    open weak var tableSection: TableSection?
    
    /// Height of the row.
    open var height: Float?
    
    /// If set to false, the cell cannot be selected. Default value of this property is `true`.
    open var allowsSelection: Bool = true

    /// If set to true, the cell can be edited. Default value is `false`.
    open var allowsEdit: Bool = false
    
    /// The actions which will displayed when editing a row. Required if `allowsEdit` is `true`.
    open var editActions: [UITableViewRowAction]?
    
    /// If set to true, deselects the row when it is selected. Default value of this property is `true`.
    open var shouldDeselectAfterSelection: Bool = true

    /// Custom user object to tag this row. This property is optional.
    open var userObject: AnyObject?

    /**
        Initializes the row.
        
        - Parameters: 
            - cellIdentifier: Either the reuse identifier of a reusable cell defined in a TableView using the interface builder, or name of an XIB file that contains one and only one UITableViewCell object.
            - inBundle: [Optional] This is the bundle that the XIB file is in. Default is nil.
    */
    public init(cellIdentifier: String, inBundle bundle: Bundle? = nil) {
        self.cellIdentifier = cellIdentifier
        self.bundle = bundle
    }

    /// Returns the cell that this row contains.
    open func cellForTableView(_ tableView: UITableView) -> UITableViewCell? {
        self.cell = loadCellForTableView(tableView)

        callConfigureCellClosure()

        guard let cell = self.cell else {
            return nil
        }

        if self.height == nil {
            self.height = Float(cell.frame.height)
        }

        return cell
    }

    /// Returns the height of cell.
    open func heightForCell() -> CGFloat {
        if let configureHeightClosure = self.configureHeightClosure {
            return CGFloat(configureHeightClosure())
        }
        
        if let height = self.height {
            return CGFloat(height)
        }

        return 44
    }

    /// Called when the row is selected.
    open func select() {
        if let closure = onSelectionClosure {
            closure(self)
        }
    }

    /**
        Adds a closure which is called when a cell will be displayed. Use this closure to display your custom data in the cell.
    */
    open func configureCell(_ closure: @escaping (_ cell:UITableViewCell) -> ()) {
        configureClosure = closure
        callConfigureCellClosure()
    }
    
    /**
        Adds a closure which is called when a cell will be displayed. Use this closure to adjust the height for cell.
    */
    open func configureHeight(_ closure: @escaping () -> Float) {
        configureHeightClosure = closure
    }

    /**
        Adds a closure which will be called when a user selects the cell. Use this to implement custom behavior when the cell is selected.
    */
    open func onSelect(_ closure: @escaping (_ row:TableRow) -> ()) {
        onSelectionClosure = closure
    }

    fileprivate func callConfigureCellClosure() {
        guard let closure = self.configureClosure else {
            return
        }

        guard let cell = self.cell else {
            return
        }

        closure(cell)
    }

    fileprivate func loadCellForTableView(_ tableViewOrNil: UITableView?) -> UITableViewCell? {
        let tableView: UITableView
        if tableViewOrNil == nil {
            tableView = UITableView()
        } else {
            tableView = tableViewOrNil as UITableView!
        }

        let dequeued = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if dequeued != nil {
            return dequeued
        } else {
            let nib: UINib = UINib(nibName: cellIdentifier, bundle: bundle)
            tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            return cell
        }
    }
}

