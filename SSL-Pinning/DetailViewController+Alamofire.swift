//
//  DetailViewController+Alamofire.swift
//  SSL-Pinning
//
//  Created by Adis on 09.12.2020..
//  Copyright © 2020 Adis. All rights reserved.
//

import Foundation
import Alamofire

extension DetailViewController {
  func requestWithAlamofire() {
    guard let urlString = endpointTextfield.text,
          let url = URL(string: urlString) else {
            showResult(success: false)
            return
          }
    
    if pinning {
      let evaluators: [String: ServerTrustEvaluating] = [
        "stackoverflow.com": PublicKeysTrustEvaluator()
      ]
      
      let manager = ServerTrustManager(evaluators: evaluators)
      
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
