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
    An object oriented implementation of UITableViewDataSource and UITableViewDelegate protocols.

    Use it in conjuction with TableSection and TableRow classes to create dynamic and configurable UITableView instances.
*/
@objcMembers open class TableViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {

    /// The table view that this section is bound to.
    open let tableView: UITableView
   
    /// The row animation that will be displayed when sections are inserted or removed.
    open var sectionAnimation: UITableViewRowAnimation

    internal fileprivate(set) var sections: NSMutableArray

    /**
        Initializes a TableViewModel with a table view.
     
        - Parameters:
            - tableView: to use with the model
    */
    public init(tableView: UITableView) {
        self.sections = NSMutableArray()
        self.tableView = tableView
        self.sectionAnimation = UITableViewRowAnimation.fade

        super.init()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()

        addObserver(self, forKeyPath: "sections", options: NSKeyValueObservingOptions.new, context: nil)
    }

    deinit {
        removeObserver(self, forKeyPath: "sections")
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey:Any]?, context: UnsafeMutableRawPointer?) {
        guard let indexSet: IndexSet = change?[NSKeyValueChangeKey.indexesKey] as? IndexSet else {
            return
        }

        guard let kind: NSKeyValueChange = NSKeyValueChange(rawValue: change?[NSKeyValueChangeKey.kindKey] as! UInt) else {
            return
        }

        self.tableView.beginUpdates()
        switch kind {
        case .insertion:
            tableView.insertSections(indexSet, with: self.sectionAnimation)
        case .removal:
            tableView.deleteSections(indexSet, with: self.sectionAnimation)
        default:
            return
        }
        tableView.endUpdates()
    }

    /**
        Adds a section to tableView.
     
        - Parameters:
            - section: The TableSection instance that describes the section.
     */
    open func addSection(_ section: TableSection) {
        assignParentsToSection(section)
        observableSections().add(section)
    }

    /**
        Inserts a section to tableView at a given index.
     
        - Parameters:
            - section: The TableSection instance that describes the section.
            - atIndex: Index at which the section will be inserted.
     */
    open func insertSection(_ section: TableSection, atIndex index: Int) {
        assignParentsToSection(section)
        observableSections().insert(section, at: index)
    }

    /**
        Removes given section from the tableView
        
        - Parameters:
            - section: The section to remove.
    */
    open func removeSection(_ section: TableSection) {
        guard self.indexOfSection(section) != NSNotFound else {
            return
        }

        removeParentsFromSection(section)
        observableSections().remove(section)
    }

    /// Removes all sections from the tableView.
    open func removeAllSections() {
        let allSections: [TableSection] = self.sections.map {
            section in
            return section as! TableSection
        }
        allSections.forEach(removeParentsFromSection)
        let sectionsProxy = self.observableSections()
        let range = NSMakeRange(0, sectionsProxy.count)
        let indexes = IndexSet(integersIn: range.toRange() ?? 0..<0)
        sectionsProxy.removeObjects(at: indexes)
    }

    fileprivate func assignParentsToSection(_ section: TableSection) {
        section.tableViewModel = self
        section.tableView = tableView
    }

    fileprivate func removeParentsFromSection(_ section: TableSection) {
        section.tableViewModel = nil
        section.tableView = nil
    }

    /**
        Returns the index of given section.

        - Parameters:
            - section: The section to return the index of.
    */
    open func indexOfSection(_ section: TableSection) -> Int {
        return sections.index(of: section)
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionAtIndex(section).numberOfRows()
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowForIndexPath(indexPath)
        let cell = row.cellForTableView(tableView) as UITableViewCell!

        return cell!
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowForIndexPath(indexPath).heightForCell()
    }
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let row = rowForIndexPath(indexPath)
        if !row.allowsSelection {
            return nil
        }
        return indexPath
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = rowForIndexPath(indexPath)

        row.select()

        if row.shouldDeselectAfterSelection {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView? {
        return self.sectionAtIndex(sectionIndex).headerView
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection sectionIndex: Int) -> CGFloat {
        return CGFloat(self.sectionAtIndex(sectionIndex).headerHeight)
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIndex: Int) -> String? {
        return self.sectionAtIndex(sectionIndex).headerTitle
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let row = rowForIndexPath(indexPath)
        return row.allowsEdit
    }
    
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let row = rowForIndexPath(indexPath)
        return row.editActions
    }

    // MARK: 
    
    fileprivate func observableSections() -> NSMutableArray {
        return mutableArrayValue(forKey: "sections")
    }

    fileprivate func sectionAtIndex(_ index: Int) -> TableSection {
        return sections[index] as! TableSection
    }

    fileprivate func rowForIndexPath(_ indexPath: IndexPath) -> TableRowProtocol {
        let section = sections[(indexPath as NSIndexPath).section] as! TableSection
        let row = section.rowAtIndex((indexPath as NSIndexPath).row)
        return row
    }

    /**
        Returns an immutable NSArray object contains all sections added to the model.
     
        - Warning: Do not try to modify this array, use add, insert and remove methods instead.
    */
    open func allSections() -> NSArray {
        return sections
    }
}
