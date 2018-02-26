//
//  RoutesTableViewController.swift
//  tpg offline
//
//  Created by Remy on 09/09/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

protocol RouteSelectionDelegate: class {
    func routeSelected(_ newRoute: Route)
}

class RoutesTableViewController: UITableViewController {

    public var route = Route() {
        didSet {
            self.tableView.reloadData()
        }
    }

    weak var delegate: RouteSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: #imageLiteral(resourceName: "reverse"), style: .plain, target: self, action: #selector(self.reverseStops))
        ]

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]

        if App.darkMode {
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.backgroundColor = .black
            self.tableView.separatorColor = App.separatorColor
        }

        ColorModeManager.shared.addColorModeDelegate(self)

        guard let rightNavController = self.splitViewController?.viewControllers.last as? UINavigationController,
            let detailViewController = rightNavController.topViewController as? RouteResultsTableViewController else { return }
        self.delegate = detailViewController
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    @objc func reverseStops() {
        let from = self.route.from
        let to = self.route.to
        self.route.from = to
        self.route.to = from
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return App.favoritesRoutes.count
        }
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "routesCell", for: indexPath)
                cell.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

                let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.textColor = App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : .white
                cell.imageView?.image = #imageLiteral(resourceName: "magnify").maskWith(color: App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : .white)
                cell.textLabel?.attributedText = NSAttributedString(string: "Search".localized, attributes: titleAttributes)
                cell.detailTextLabel?.text = ""
                cell.accessoryType = .disclosureIndicator

                let selectedView = UIView()
                selectedView.backgroundColor = cell.backgroundColor?.darken(by: 0.1)
                cell.selectedBackgroundView = selectedView

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "routesCell", for: indexPath)
                let titleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline)]
                let subtitleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline)]
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.textColor = App.textColor
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.textColor = App.textColor
                cell.backgroundColor = App.cellBackgroundColor

                if App.darkMode {
                    let selectedView = UIView()
                    selectedView.backgroundColor = .black
                    cell.selectedBackgroundView = selectedView
                } else {
                    let selectedView = UIView()
                    selectedView.backgroundColor = UIColor.white.darken(by: 0.1)
                    cell.selectedBackgroundView = selectedView
                }

                switch indexPath.row {
                case 0:
                    cell.imageView?.image = #imageLiteral(resourceName: "from").maskWith(color: App.textColor)
                    cell.textLabel?.attributedText = NSAttributedString(string: "From".localized, attributes: titleAttributes)
                    cell.detailTextLabel?.attributedText = NSAttributedString(string: self.route.from?.name ?? "", attributes: subtitleAttributes)
                case 1:
                    cell.imageView?.image = #imageLiteral(resourceName: "to").maskWith(color: App.textColor)
                    cell.textLabel?.attributedText = NSAttributedString(string: "To".localized, attributes: titleAttributes)
                    cell.detailTextLabel?.attributedText = NSAttributedString(string: self.route.to?.name ?? "", attributes: subtitleAttributes)
                case 2:
                    cell.imageView?.image = #imageLiteral(resourceName: "clock").maskWith(color: App.textColor)
                    cell.textLabel?.attributedText = NSAttributedString(string: self.route.arrivalTime ?
                        "Arrival at".localized : "Departure at".localized, attributes: titleAttributes)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = Calendar.current.isDateInToday(self.route.date) ? .none : .short
                    dateFormatter.timeStyle = .short
                    cell.detailTextLabel?.attributedText = NSAttributedString(string: dateFormatter.string(from: self.route.date),
                                                                              attributes: subtitleAttributes)
                default:
                    print("WTF ?!")
                }
                return cell
            }
        } else {
            self.tableView.deselectRow(at: indexPath, animated: true)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteRouteCell", for: indexPath) as? FavoriteRouteTableViewCell
                else { return UITableViewCell() }
            cell.route = App.favoritesRoutes[indexPath.row]
            return cell
        }
    }

    @objc func search() {
        if route.validRoute {
            self.delegate?.routeSelected(self.route)
            if let detailViewController = delegate as? RouteResultsTableViewController,
                let detailNavigationController = detailViewController.navigationController {
                splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
                detailNavigationController.popToRootViewController(animated: false)
            }
        } else {
            let alertView = UIAlertController(title: "Invalid route".localized, message: "Are you sure you set the departure stop and the arrival stop?".localized, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertView, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStopsForRoute" {
            guard let indexPath = sender as? IndexPath else { return }
            guard let destinationViewController = segue.destination as? StopsForRouteTableViewController else {
                return
            }
            destinationViewController.isFrom = indexPath.row == 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.route = App.favoritesRoutes[indexPath.row]
            self.route.date = Date()
            self.route.arrivalTime = false
            search()
            return
        }
        switch indexPath.row {
        case 0:
            App.log("Selected from stop select")
            performSegue(withIdentifier: "showStopsForRoute", sender: indexPath)
        case 1:
            App.log("Selected to stop select")
            performSegue(withIdentifier: "showStopsForRoute", sender: indexPath)
        case 2:
            App.log("Selected date select")
            DatePickerDialog(showCancelButton: false).show("Select date".localized,
                                                           doneButtonTitle: "OK".localized,
                                                           cancelButtonTitle: "Cancel".localized,
                                                           nowButtonTitle: "Now".localized,
                                                           defaultDate: self.route.date,
                                                           minimumDate: nil,
                                                           maximumDate: nil,
                                                           datePickerMode: .dateAndTime,
                                                           arrivalTime: self.route.arrivalTime) { arrivalTime, date in
                                                            if let date = date {
                                                                self.route.date = date
                                                                self.route.arrivalTime = arrivalTime
                                                                print(arrivalTime)
                                                            }
            }
        case 3:
            search()
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row == 2 && indexPath.section == 0) || indexPath.section == 1
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            let setToNowAction = UITableViewRowAction(style: .normal, title: "Now".localized) { (_, _) in
                self.route.date = Date()
            }
            if App.darkMode {
                setToNowAction.backgroundColor = .black
            } else {
                setToNowAction.backgroundColor = #colorLiteral(red: 0.2470588235, green: 0.3176470588, blue: 0.7098039216, alpha: 1)
            }
            return [setToNowAction]
        } else {
            let reverseAction = UITableViewRowAction(style: .normal, title: "Reversed".localized) { (_, _) in
                self.route = App.favoritesRoutes[indexPath.row]
                let from = self.route.from
                let to = self.route.to
                self.route.from = to
                self.route.to = from
                self.route.date = Date()
                self.search()
            }
            if App.darkMode {
                reverseAction.backgroundColor = .black
            } else {
                reverseAction.backgroundColor = #colorLiteral(red: 0.6117647059, green: 0.1529411765, blue: 0.6901960784, alpha: 1)
            }
            return [reverseAction]
        }
    }
}

extension RoutesTableViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
