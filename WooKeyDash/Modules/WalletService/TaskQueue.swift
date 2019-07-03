//   
//   WalletTaskQueue.swift
//   WooKeyDash
//   
//  Created by WooKey Team on 2019/5/23
//   Copyright © 2019 WooKey. All rights reserved.
//   
	

import Foundation

typealias TaskClosure = (() -> Void)

private enum TaskIndetinfy {
    case safe
    case `default`
    case main
}

let safeQueue = {
    DispatchQueue(label: AppInfo.bundleIdentifier + "-wallettask")
}()

private func onThread(_ taskIndetinfy: TaskIndetinfy = .default, taskClosure: TaskClosure?) {
    guard let closure = taskClosure else { return }
    let queue: DispatchQueue
    switch taskIndetinfy {
    case .safe:
        queue = safeQueue
    case .main:
        queue = DispatchQueue.main
    default:
        queue = DispatchQueue.global()
    }
    queue.async(execute: closure)
}

func safeTask(_ closure: TaskClosure?) {
    onThread(.safe, taskClosure: closure)
}

func mainTask(_ closure: TaskClosure?) {
    onThread(.main, taskClosure: closure)
}

func globalTask(_ closure: TaskClosure?) {
    onThread(.default, taskClosure: closure)
}
