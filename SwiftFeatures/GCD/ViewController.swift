//
//  ViewController.swift
//  GCD
//
//  Created by 王正一 on 2017/3/10.
//  Copyright © 2017年 FsThatOne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tableView: UITableView = {
        let table = UITableView(frame: UIScreen.main.bounds)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var dataSource: Array<String> = ["串行队列同步执行", "串行队列异步执行", "并行队列同步执行", "并行队列异步执行"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // 串行队列同步执行
    func performQueueSynchronization(queue: DispatchQueue) {
        for i in 1...10 {
            queue.sync {
                self.sleepFor(period: 1)
                print("当前执行线程为:\(self.currentThread())")
                print("执行\(i)")
            }
        }
        print("所有同步线程已执行完毕")
    }
    // 串行队列异步执行
    func performQueueAsynchronization(queue: DispatchQueue) {
        for i in 1...10 {
            queue.sync {
                self.sleepFor(period: 1)
                print("当前执行线程为:\(self.currentThread())")
                print("执行\(i)")
            }
        }
        print("所有同步线程已执行完毕")
    }

    
}

extension ViewController {
    // 获取当前线程
    func currentThread() -> Thread {
        let currentThread = Thread.current
        return currentThread
    }
    // 休眠一段时间
    func sleepFor(period time: TimeInterval) {
        Thread.sleep(forTimeInterval: time)
    }
    // 获取主队列
    func getMainThread() -> DispatchQueue {
        return DispatchQueue.main
    }
    // 获取全局队列,默认优先级,也可以自己定义优先级
    func getGlobalQueue(priority: DispatchQoS.QoSClass = .default) -> DispatchQueue {
        let globalQueue = DispatchQueue.global(qos: priority)
        return globalQueue
    }
    // 创建并行队列
    func getSerialQueue(queueId label: String) -> DispatchQueue {
        let serialQueue = DispatchQueue(label: label)
        return serialQueue
    }
    // 创建穿行队列
    func getConcurrentQueue(queueId label: String) -> DispatchQueue {
        let concurrentQueue = DispatchQueue(label: label, attributes: [.concurrent])
        return concurrentQueue
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell.textLabel?.text = dataSource[indexPath.row]
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = dataSource[indexPath.row]
            return cell
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        case 5:
            break
        case 6:
            break
        case 7:
            break
        case 8:
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
