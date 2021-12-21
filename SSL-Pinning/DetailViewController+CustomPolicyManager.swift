//
//  DetailViewController+CustomPolicyManager.swift
//  SSL-Pinning
//
//  Created by Adis on 09.12.2020..
//  Copyright © 2020 Adis. All rights reserved.
//

import Foundation
import Alamofire

final class DenyEvaluator: ServerTrustEvaluating {
  func evaluate(_ trust: SecTrust, forHost host: String) throws {
    throw AFError.serverTrustEvaluationFailed(reason: .noPublicKeysFound)
  }
}

final class CustomServerTrustPolicyManager: ServerTrustManager {
  init() {
    super.init(evaluators: [:])
  }
  
  override func serverTrustEvaluator(forHost host: String) throws -> ServerTrustEvaluating? {
    if host == "stackoverflow.com" {
      return PublicKeysTrustEvaluator()
    } else {
      return DenyEvaluator()
    }
  }
}

extension DetailViewController {
  func requestWithCustomPolicyManager() {
    guard let urlString = endpointTextfield.text,
          let url = URL(string: urlString) else {
            showResult(success: false)
            return
          }
    
    if pinning {
      let manager = CustomServerTrustPolicyManager()
      session = Session(serverTrustManager: manager)
    } else {
      session = Session()
    }
    
    session!
      .request(url, method: .get)
      .validate()
      .response(completionHandler: { [weak self] response in
        switch response.result {
        case .success:
          self?.showResult(success: true)
        case .failure(let error):
          switch error {
          case .serverTrustEvaluationFailed(let reason):
            print(reason)
            self?.showResult(success: false, pinError: true)
          default:
            self?.showResult(success: false)
          }
        }
      })
  }
}
