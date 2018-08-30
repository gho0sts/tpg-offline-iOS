//
//  IntentViewController.swift
//  tpg offline SiriUI
//
//  Created by レミー on 13/07/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import IntentsUI
class IntentViewController: UIViewController, INUIHostedViewControlling {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleLabel: UILabel!

  var departures: [String] = [] {
    didSet {
      self.tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  func configureView(for parameters: Set<INParameter>,
                     of interaction: INInteraction,
                     interactiveBehavior: INUIInteractiveBehavior,
                     context: INUIHostedViewContext,
                     completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
    guard let intent = interaction.intent as? DeparturesIntent,
      let intentResponse = interaction.intentResponse as? DeparturesIntentResponse
      else { return }
    titleLabel.text = intent.stop?.displayString ?? ""

    var departuresTemp: [String] = []
    for departure in (intentResponse.departures ?? []) {
      if let id = departure.identifier {
        departuresTemp.append(id)
      }
    }
    departures = departuresTemp

    completion(true, parameters, self.desiredSize)
  }

  var desiredSize: CGSize {
    return self.extensionContext!.hostedViewMaximumAllowedSize
  }
}

extension IntentViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return departures.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell",
                                                   for: indexPath)
      as? SiriDepartureCell else {
        return UITableViewCell()
    }
    cell.departureString = self.departures[indexPath.row]
    return cell
  }
}

class SiriDepartureCell: UITableViewCell {
  @IBOutlet weak var lineLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var leftTimeLabel: UILabel!

  var departureString = "" {
    didSet {
      let components = departureString.split(separator: ",")
      guard components.count == 3 else { return }
      let line = String(components[0])
      let destination = String(components[1])
      let leftTime = String(components[2])

      lineLabel.text = line
      destinationLabel.text = destination
      leftTimeLabel.text = "\(leftTime)'"
      
      lineLabel.textColor = LineColorManager.color(for: line).contrast
      lineLabel.backgroundColor = LineColorManager.color(for: line)
      lineLabel.layer.cornerRadius = lineLabel.bounds.height / 2
      lineLabel.clipsToBounds = true
    }
  }
}