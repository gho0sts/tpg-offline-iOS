//
//  CreditsTableViewController.swift
//  tpg offline
//
//  Created by Alice on 29/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import ChameleonFramework

class CreditsTableViewController: UITableViewController {

    let listeCredits = [
        ["Open data des Transports Publics Genevois", "Données fournis par la société des Transports Publics Genevois"],
        ["Open data de Transport API", "Données fournis par Opendata.ch"],
        ["SwiftyJSON", "Project maintenu sur GitHub par SwiftyJSON - Project en licence MIT"],
        ["Chamelon", "Project maintenu sur GitHub par ViccAlexander - Project en licence MIT"],
        ["FontAwesomeKit", "Project maintenu sur GitHub par PrideChung - Project en licence MIT"],
        ["BGTableViewRowActionWithImage", "Project maintenu sur GitHub par benguild - Project en licence MIT"],
        ["SCLAlertView-Swift", "Project maintenu sur GitHub par vikmeup - Project en licence MIT"],
        ["FSCalendar", "Project maintenu sur GitHub par WenchaoIOS - Project en licence MIT"],
        ["DGRunkeeperSwitch", "Project maintenu sur GitHub par gontovnik - Project en licence MIT"],
		["EFCircularSlider", "Project maintenu sur GitHub par eliotfowler et modifié par RemyDCF - Project en licence MIT"],
		["PermissionScope", "Project maintenu sur GitHub par nickoneill - Project en licence MIT"]
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = AppValues.primaryColor
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        tableView.backgroundColor = AppValues.primaryColor
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listeCredits.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("creditsCell", forIndexPath: indexPath)

        cell.textLabel?.text = listeCredits[indexPath.row][0]
        cell.detailTextLabel?.text = listeCredits[indexPath.row][1]
        cell.textLabel?.textColor = AppValues.textColor
        cell.detailTextLabel?.textColor = AppValues.textColor
        cell.backgroundColor = AppValues.primaryColor
        
        let view = UIView()
        view.backgroundColor = AppValues.secondaryColor
        cell.selectedBackgroundView = view
        
        return cell
    }
}
