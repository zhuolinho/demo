//
//  NewSportController.swift
//  demo
//
//  Created by HoJolin on 15/4/6.
//  Copyright (c) 2015年 CBC. All rights reserved.
//

import UIKit

class NewSportController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var picCollection: UICollectionView!
    @IBOutlet weak var timesLabel: UILabel!
    @IBOutlet weak var meneyTextField: UITextField!
    var picker = UIPickerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        var blankView = UIView(frame: CGRectZero)
        tableView.tableFooterView = blankView
        var commitButton = UIButton(frame: CGRect(x: 0, y: view.bounds.height - 125, width: view.bounds.width, height: 60))
        commitButton.setTitle("发布任务", forState: UIControlState.Normal)
        commitButton.backgroundColor = UIColor.orangeColor()
        commitButton.titleLabel?.textColor = UIColor.whiteColor()
        view.addSubview(commitButton)
        picker = UIPickerView(frame: CGRect(x: 0, y: view.bounds.height - 314, width: view.bounds.width, height: 162))
        picker.backgroundColor = UIColor.whiteColor()
        picker.dataSource = self
        picker.delegate = self
        picker.hidden = true
        view.addSubview(picker)
        picCollection.dataSource = self
        picCollection.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        meneyTextField.resignFirstResponder()
        picker.hidden = true
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timesLabel.text = String(row)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            picker.hidden = false
        }
    }
    // MARK: - Table view data source
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return String(row)
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as UICollectionViewCell
        return cell
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
