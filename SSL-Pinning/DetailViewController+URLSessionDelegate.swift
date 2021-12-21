//
//  DetailViewController+URLSessionDelegate.swift
//  SSL-Pinning
//
//  Created by Adis on 23.12.2020..
//  Copyright © 2020 Adis. All rights reserved.
//

import Foundation

extension DetailViewController {
  func requestWithURLSessionDelegate() {
    guard let urlString = endpointTextfield.text,
          let url = URL(string: urlString) else {
            showResult(success: false)
            return
          }
    
    /// When not pinning, we simply skip setting our own delegate
    let session = URLSession(configuration: .default, delegate: pinning ? self : nil, delegateQueue: nil)
    
    let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
      DispatchQueue.main.async { [weak self] in
        if response != nil { self?.showResult(success: true) }
      }
    })
    
    task.resume()
  }
}

extension DetailViewController: URLSessionDelegate {
  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
      completionHandler(.cancelAuthenticationChallenge, nil)
      return
    }

    if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0),
       let serverCertificateKey = publicKey(for: serverCertificate) {
      // Compara as chave do certificado no bundle com a chave do host.
      if let pinKey = pinnedKey, serverCertificateKey == pinKey {
        completionHandler(.useCredential, URLCredential(trust: trust))
        return
      } else {
        completionHandler(.cancelAuthenticationChallenge, nil)
        showResult(success: false, pinError: true)
        return
      }
    }

    completionHandler(.cancelAuthenticationChallenge, nil)
    showResult(success: false)
  }
  
  var pinnedKey: SecKey? {
    do {
      let pinnedCertificateData = try Data(contentsOf: validCertURL) as CFData
      if let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData), let key = publicKey(for: pinnedCertificate) {
        return key
      }
    } catch {
      // Handle error
    }
    return nil
  }

  private func publicKey(for certificate: SecCertificate) -> SecKey? {
    let policy = SecPolicyCreateBasicX509()
    var trust: SecTrust?
    let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)

    guard let trust = trust, trustCreationStatus == errSecSuccess else {
      return nil
    }

    return SecTrustCopyKey(trust)
  }
}
