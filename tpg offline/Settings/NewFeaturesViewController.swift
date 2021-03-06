//
//  NewFeaturesViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 22/12/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

struct Feature {
  let image: UIImage
  let title: String
  let text: String
}

class NewFeaturesViewController: UIViewController {

  @IBOutlet weak var cityImageView: UIImageView!
  @IBOutlet var clouds: [UIImageView]!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var newFeaturesLabel: UILabel!
  @IBOutlet weak var dismissButton: UIButton!

  var features: [Feature] = [] {
    didSet {
      self.tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    ColorModeManager.shared.addColorModeDelegate(self)

    // swiftlint:disable line_length
    features.append(Feature(image: #imageLiteral(resourceName: "pinMapNavBar"), title: "Line 62 and 63 and maps".localized, text: "tpg offline is now up to date with the tpg network".localized))
     features.append(Feature(image: #imageLiteral(resourceName: "bug"), title: "Stability improvements".localized, text: "We improved the stability and we made some cosmetic improvements.".localized))
    // swiftlint:enable line_length

    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
      as? String {
      UserDefaults.standard.set(version, forKey: "lastVersion")
    }

    if App.darkMode {
      self.tableView.sectionIndexBackgroundColor = App.cellBackgroundColor
      self.tableView.backgroundColor = .black
      self.view.backgroundColor = .black
      self.newFeaturesLabel.textColor = .white
    }

    for cloud in clouds {
      cloud.image = #imageLiteral(resourceName: "cloud").maskWith(color: App.textColor)
    }

    self.newFeaturesLabel.text = "What's new!".localized

    self.dismissButton.setTitle("Dismiss".localized, for: .normal)
    self.dismissButton.setTitleColor(App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : .white, for: .normal)
    self.dismissButton.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
    self.dismissButton.cornerRadius = self.dismissButton.bounds.height / 2
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print(scrollView.contentOffset)
    cityImageView.transform =
      CGAffineTransform(translationX: scrollView.contentOffset.y / -5, y: 0)
    for cloud in clouds {
      cloud.transform =
        CGAffineTransform(translationX: scrollView.contentOffset.y / -10, y: 0)
    }
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
      return UIInterfaceOrientationMask.portrait
    } else {
      return .all
    }
  }

  @IBAction func exit() {
    self.dismiss(animated: true, completion: nil)
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
}

extension NewFeaturesViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return features.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell =
      tableView.dequeueReusableCell(withIdentifier: "newFeature", for: indexPath)
        as? NewFeaturesTableViewCell else { return UITableViewCell() }
    cell.feature = features[indexPath.row]
    return cell
  }
}
