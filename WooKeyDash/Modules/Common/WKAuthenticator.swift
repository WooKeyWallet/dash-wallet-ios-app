//
//  WKAuthenticator.swift
//  WooKeyDash
//
//  Created by WooKey Team on 2019/5/28.
//  Copyright © 2019 WooKey. All rights reserved.
//

import UIKit
import LocalAuthentication

class WKAuthenticator: NSObject {
    
    // MARK: - Structs
    
    private struct KeyPath {
        static let pin = "yneikp"
        static let touchOrFaceId = "diecafhcuot"
    }
    
    // MARK: - Properties (Public)

    static let shared = { WKAuthenticator() }()
    
    var hasPin: Bool {
        return UserDefaults.standard.string(forKey: KeyPath.pin) != nil
    }
    
    var hasTouchOrFaceId: Bool {
        get { return UserDefaults.standard.bool(forKey: KeyPath.touchOrFaceId) }
        set {
            UserDefaults.standard.setValue(newValue, forKey: KeyPath.touchOrFaceId)
        }
    }
    
    var firstSetFaceID: Bool {
        get {
            return
                faceIDAvailable()
                && UserDefaults.standard.value(forKey: KeyPath.touchOrFaceId) == nil
        }
    }
    
    // MARK: - Properties (Private)
    
    var context: LAContext?
    
    
    // MARK: - Life Cycles
    
    override init() {
        super.init()
    }
    
    func request(_ result: ((Bool) -> Void)?) {
        guard hasTouchOrFaceId else {
            loginByPassCode(result)
            return
        }
        context = LAContext()
        var error: NSError?
        guard context!.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        else {
            loginByPassCode(result)
            return
        }
        context!.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Touch to unlock") { (success, err) in
            DispatchQueue.main.async {
                if success {
                    result?(true)
                } else {
                    if let err = err as? LAError {
                        self.onError(err, result: result)
                    } else {
                        result?(false)
                    }
                }
            }
        }
    }
    
    func setPasscode(_ text: String) {
        UserDefaults.standard.set(text.sha256(), forKey: KeyPath.pin)
    }
    
    func verifyPasscode(_ text: String) -> Bool {
        guard let shaCode = UserDefaults.standard.string(forKey: KeyPath.pin) else { return false }
        return shaCode == text.sha256()
    }
    
    private func onError(_ error: LAError, result: ((Bool) -> Void)?) {
        switch Int32(error.errorCode) {
        case kLAErrorAuthenticationFailed:
            HUD.showError(LocalizedString(key: "failToVerify", comment: "")); result?(false)
        case kLAErrorUserFallback, kLAErrorBiometryNotAvailable, kLAErrorBiometryNotEnrolled, kLAErrorBiometryLockout:
            loginByPassCode(result)
        default:
            break
        }
    }
    
    private func loginByPassCode(_ result: ((Bool) -> Void)?) {
        PINAlertController.show { (success) in
            result?(success)
        }
    }
    
    /// checks if device supports face id authentication
    func faceIDAvailable() -> Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            return (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) && context.biometryType == .faceID)
        }
        return false
    }
    
    /// checks if device supports touch id authentication
    func touchIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if #available(iOS 11.0, *) {
            return canEvaluate && context.biometryType == .touchID
        }
        return canEvaluate
    }
    
}
