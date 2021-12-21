//
//  DetailViewController.swift
//  SSL-Pinning
//
//  Created by Adis on 30/08/2020.
//  Copyright © 2020 Adis. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController {
  
  @IBOutlet var pinEnabledSwitch: UISwitch!
  @IBOutlet var endpointTextfield: UITextField!
  @IBOutlet var resultLabel: UILabel!
  
  var method: PinMethod = .alamofire
  var session: Session?
  var pinning: Bool { pinEnabledSwitch.isOn }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    /// Edit this textfield to enter another domain and simulate mismatched certificates
    endpointTextfield.text = "https://stackoverflow.com/"
  }
  
  @IBAction private func testPin() {
    switch method {
    case .alamofire:
      requestWithAlamofire()
    case .NSURLSession:
      requestWithURLSessionDelegate()
    case .customPolicyManager:
      requestWithCustomPolicyManager()
    }
  }
  
  func showResult(success: Bool, pinError: Bool = false) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      if success {
        self.resultLabel.text = "Success \\o/"
      } else {
        if pinError {
          self.resultLabel.text = "Pinning Failed!"
        } else {
          self.resultLabel.text = "Request failed!"
        }
      }
    }
  }
}

extension DetailViewController {
  var validCertURL: URL {
    return Bundle.main.url(forResource: "stackexchange", withExtension: "cer")!
  }
  
  var invalidCertURL: URL {
    return Bundle.main.url(forResource: "stackexchange", withExtension: "cer")!
  }
}
