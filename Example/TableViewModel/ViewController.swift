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

import UIKit
import TableViewModel

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var tableViewModel: TableViewModel!
    var topSection: TableSection!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewModel = TableViewModel(tableView: self.tableView)

        addFeedSection()
        addRemovableSection()
        self.perform(#selector(ViewController.insertGiveFeedbackRow), with: nil, afterDelay: 3)
        self.perform(#selector(ViewController.insertRemovableRow), with: nil, afterDelay: 5)
        self.perform(#selector(ViewController.insertFeedRow), with: nil, afterDelay: 7)
    }

    func addFeedSection() {
        // Create the section and add it to the model
        topSection = TableSection()
        topSection.headerTitle = "Newsfeed"
        topSection.headerHeight = 30
        tableViewModel.addSection(topSection)

        // Get the sample data for this section
        let sampleFeed = FeedItem.initialItems()

        // Create rows for feed items
        for feedItem in sampleFeed {
            // Create a row for each feed item
            let row = TableRow(cellIdentifier: "FeedCell")

            // Configure the cell
            configureFeedRow(row, withFeedItem: feedItem)

            // Add the row to the section
            topSection.addRow(row)
        }

        // Add a spacer to the bottom of the section
        topSection.addRow(TableRow(cellIdentifier: "SpacerCell"))
    }

    func onLike(_ feedItem: FeedItem) {
        self.alert("Liked: \(feedItem.user.name)")
    }

    func onShare(_ feedItem: FeedItem) {
        self.alert("Shared: \(feedItem.user.name)")
    }

    func addRemovableSection() {
        // Create the section and add it to the model
        let removableSection = TableSection()
        tableViewModel.addSection(removableSection)

        // Create the header for the section and set it as the header view of section
        let removableSectionHeader = Bundle.main.loadNibNamed("RemovableSectionHeader", owner: nil, options: nil)?[0] as! RemovableSectionHeader
        removableSection.headerView = removableSectionHeader
        removableSection.headerHeight = 30

        // When remove button is tapped on the header view, remove the section from the model
        removableSectionHeader.onRemoveTap {
            self.tableViewModel.removeSection(removableSection)
        }

        // Create rows for sample feed items
        let removableItems = FeedItem.removableSectionItems()
        for feedItem in removableItems {
            let row = TableRow(cellIdentifier: "FeedCell")
            configureFeedRow(row, withFeedItem: feedItem)
            removableSection.addRow(row)
        }

        // Add a specer to the bottom of the section
        removableSection.addRow(TableRow(cellIdentifier: "SpacerCell"))
    }

    func insertGiveFeedbackRow() {
        topSection.rowAnimation = UITableViewRowAnimation.top
        let row = TableRow(cellIdentifier: "GiveFeedbackCell")
        row.onSelect {
            row in
            self.alert("Feedback row clicked!")
        }
        topSection.insertRow(row, atIndex: 0)
    }

    func insertRemovableRow() {
        topSection.rowAnimation = UITableViewRowAnimation.right
        let row = TableRow(cellIdentifier: "RemovableCell")
        row.onSelect {
            row in
            self.topSection.removeRow(row)
        }
        row.allowsEdit = true
        row.editActions = {
            // Delete actions
            let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action , indexPath) -> Void in
                row.tableSection?.removeRow(row)
            })
            deleteAction.backgroundColor = UIColor.red
            return [deleteAction]
        }()
        
        topSection.insertRow(row, atIndex: 1)
    }

    func insertFeedRow() {
        topSection.rowAnimation = UITableViewRowAnimation.left
        let feedItem = FeedItem.toBeAddedLater()
        let row = TableRow(cellIdentifier: "FeedCell")
        configureFeedRow(row, withFeedItem: feedItem)
        topSection.insertRow(row, atIndex: topSection.numberOfRows() - 1)
    }

    func configureFeedRow(_ row: TableRow, withFeedItem feedItem: FeedItem) {
        row.configureCell {
            cell in
            let feedCell = cell as! FeedCell
            feedCell.feedItem = feedItem
            feedCell.onLike = self.onLike
            feedCell.onShare = self.onShare

            // Cell height will change based on length of the comment. FeedCell will calculate
            // own height based on the feedItem given. We need to set this value as the height
            // of row.
            row.height = feedCell.cellHeight
        }
    }

    func alert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            action in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

}

