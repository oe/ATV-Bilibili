//
//  LoginViewController.swift
//  BilibiliLive
//
//  Created by Etan Chen on 2021/3/28.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation

class LoginViewController: UIViewController {
    
    @IBOutlet weak var qrcodeImageView: UIImageView!
    var currentLevel:Int = 0, finalLevel:Int = 200
    var timer: Timer?
    var oauthKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qrcodeImageView.image = nil
        stopValidationTimer()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    func initValidation() -> Void {
        timer?.invalidate()
        ApiRequest.requestLoginQR { (code, url) in
            self.qrcodeImageView.image = self.generateQRCode(from: url)
            self.oauthKey = code
            self.startValidationTimer()
        }
    }
    
    
    func startValidationTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentLevel += 1
            if self.currentLevel > self.finalLevel {
                self.stopValidationTimer()
            }
            self.loopValidation()
        }
    }
    
    func stopValidationTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func didValidationSuccess() {
        qrcodeImageView.image = nil
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Success", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func loopValidation() -> Void{
        
        ApiRequest.verifyLoginQR(code: oauthKey) {
            [weak self] state in
            guard let self = self else { return }
            switch state {
            case .expire:
                self.initValidation()
            case .waiting:
                break
            case .success(let token):
                print(token)
                UserDefaults.standard.set(token, forKey: "token")
            case .fail:
                break
            }
        }
    }
    
    @IBAction func actionStart(_ sender: Any) {
        initValidation()
    }
}



