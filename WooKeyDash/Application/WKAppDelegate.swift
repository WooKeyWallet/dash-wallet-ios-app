//
//  AppDelegate.swift
//  Wookey

import UIKit

@objc public class WKAppDelegate: NSObject {
    
    // MARK: - Properties (Public)
    
    @objc static let shared = { WKAppDelegate() }()
    
    
    // MARK: - Properties (Private)
    
    private var visualEffectView: UIVisualEffectView?


    // MARK: - Life Cycles
    
    @objc
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    @objc
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppManager.default.configure { () -> UIViewController in
            if WalletService.shared.hasWallet {
                guard WKAuthenticator.shared.hasPin else {
                    return NavigationController(rootViewController: PinCodeSetViewController())
                }
                return NavigationController(rootViewController: TabBarController())
            }
            return NavigationController(rootViewController: AddWalletViewController())
        }
        AppManager.default.rootIn {
            /// configure on threading
            do // main
            {
                WalletService.shared.setup()
                AppManager.default.configureIQKeyboard()
                HUD.setupAppearence()
            }
            // global
            DispatchQueue.global().async {
                
            }
        }
        return true
    }
    
    @objc
    func applicationWillResignActive(_ application: UIApplication) {
        addBlurForWindow()
    }

    @objc
    func applicationDidEnterBackground(_ application: UIApplication) {
        AppManager.default.beginBackgroundTask()
        WalletService.shared.pasueSync()
    }

    @objc
    func applicationWillEnterForeground(_ application: UIApplication) {
        removeBlurForWindow()
        WalletService.shared.startSync()
    }

    @objc
    func applicationDidBecomeActive(_ application: UIApplication) {
        removeBlurForWindow()
    }

    @objc
    func applicationWillTerminate(_ application: UIApplication) {
        
    }


}


extension WKAppDelegate {
    
    // MARK: - Methods (Private)
    
    private func addBlurForWindow() {
        let blur: UIBlurEffect
        blur = UIBlurEffect(style: .light)
        let visualView = VisualEffectView(effect: blur)
        visualView.frame = UIApplication.shared.keyWindow?.bounds ?? .zero
        visualView.blurRadius = px(18)
        UIApplication.shared.keyWindow?.addSubview(visualView)
        self.visualEffectView = visualView
    }
    
    private func removeBlurForWindow() {
        guard let visualEffectView = self.visualEffectView else { return }
        visualEffectView.removeFromSuperview()
        self.visualEffectView = nil
    }
}

