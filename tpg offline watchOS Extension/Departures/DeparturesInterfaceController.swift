//
//  DeparturesInterfaceController.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy Da Costa Faro on 08/11/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import WatchKit
import Foundation

class DeparturesInterfaceController: WKInterfaceController, DeparturesDelegate {
  var departures: DeparturesGroup? = nil {
    didSet {
      loadingImage.setImage(nil)
      guard let a = self.departures else {
        if DeparturesManager.shared.status == .loading {
          loadingImage.setImageNamed("loading-")
          loadingImage.startAnimatingWithImages(in: NSRange(location: 0,
                                                            length: 60),
                                                duration: 2,
                                                repeatCount: -1)
        }
        tableView.setNumberOfRows(0, withRowType: "linesRow")
        return
      }
      let departures = a.departures.filter({ $0.line.code == self.line })
      tableView.setNumberOfRows(departures.count, withRowType: "departureCell")

      for (index, departure) in departures.enumerated() {
        guard let rowController = self.tableView.rowController(at: index)
          as? DepartureRowController else { continue }
        rowController.departure = departure
      }
    }
  }

  var line: String = ""

  @IBOutlet weak var tableView: WKInterfaceTable!
  @IBOutlet weak var loadingImage: WKInterfaceImage!

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)

    DeparturesManager.shared.addDeparturesDelegate(delegate: self)

    guard let option = context as? [Any] else {
      print("Context is not in a valid format")
      return
    }
    guard let departures = option[0] as? DeparturesGroup else {
      print("Context is not in a valid format")
      return
    }
    guard let line = option[1] as? String else {
      print("Context is not in a valid format")
      return
    }
    self.line = line
    self.departures = departures
    self.setTitle(Text.line(line))
    self.addMenuItem(with: WKMenuItemIcon.resume,
                     title: Text.reload,
                     action: #selector(self.refreshDepartures))
  }

  @objc func refreshDepartures() {
    DeparturesManager.shared.departures = nil
    loadingImage.setImageNamed("loading-")
    loadingImage.startAnimatingWithImages(in: NSRange(location: 0,
                                                      length: 60),
                                          duration: 2,
                                          repeatCount: -1)
    DeparturesManager.shared.refreshDepartures()
  }

  deinit {
    DeparturesManager.shared.removeDeparturesDelegate(delegate: self)
  }

  func departuresDidUpdate() {
    self.departures = DeparturesManager.shared.departures
  }

  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    guard let rowController = self.tableView.rowController(at: rowIndex)
      as? DepartureRowController else { return }
    if rowController.canBeSelected {
      if rowController.departure.leftTime == "0" {
        let action = WKAlertAction(title: Text.ok, style: .default, handler: {})
        self.presentAlert(withTitle: Text.busIsComming,
                          message: Text.cantSetATimer,
                          preferredStyle: .alert, actions: [action])
      } else {
        presentController(withName: "reminderInterface",
                          context: rowController.departure)
      }
    }
  }
}

class DepartureRowController: NSObject {
  @IBOutlet var platformLabel: WKInterfaceLabel!
  @IBOutlet var destinationLabel: WKInterfaceLabel!
  @IBOutlet var leftTimeLabel: WKInterfaceLabel!

  var canBeSelected: Bool = true

  var departure: Departure! {
    didSet {
      self.destinationLabel.setText(departure.line.destination)
      switch departure.leftTime {
      case "&gt;1h":
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        let time = dateFormatter.date(from: departure.timestamp)
        if let time = time {
          self.leftTimeLabel.setText(DateFormatter.localizedString(
            from: time,
            dateStyle: DateFormatter.Style.none,
            timeStyle: DateFormatter.Style.short))
        } else {
          self.leftTimeLabel.setText("?")
          self.canBeSelected = false
        }
      case "no more":
        self.leftTimeLabel.setText("X")
        self.canBeSelected = false
      default:
        let tilde = departure.reliability == .theoretical ? "~" : ""
        leftTimeLabel.setText("\(tilde)\(departure.leftTime.time)'")
      }

      if let platform = departure.platform {
        platformLabel.setText(Text.platform(platform))
        platformLabel.setHidden(false)
      } else {
        platformLabel.setHidden(true)
      }
    }
  }
}
