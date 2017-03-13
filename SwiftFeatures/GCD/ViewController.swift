//
//  ViewController.swift
//  GCD
//
//  Created by 王正一 on 2017/3/10.
//  Copyright © 2017年 FsThatOne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var tableView: UITableView = {
        let table = UITableView(frame: UIScreen.main.bounds)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var dataSource: Array<[String]> = [["串行队列同步执行", "串行队列异步执行", "并行队列同步执行", "并行队列异步执行", "串行队列异步延迟执行", "全局队列优先级", "为自己创建的queue设置优先级", "队列与组自动关联并异步执行", "队列与组手动关联并异步执行", "信号量同步锁"], ["队列的挂起和唤醒", "任务栅栏", "源事件 - add", "源事件 - 定时器"]]
    
    override func loadView() {
        tableView.dataSource = self
        tableView.delegate = self
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /// 基础
    // 队列同步执行
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
    // 队列异步执行
    func performQueueAsynchronization(queue: DispatchQueue) {
        for i in 1...10 {
            queue.async {
                self.sleepFor(period: 1)
                print("当前执行线程为:\(self.currentThread())")
                print("执行\(i)")
            }
        }
        print("所有同步线程已执行完毕")
    }
    // 串行队列异步延迟执行
    func deferPerform(queue: DispatchQueue, delay time: TimeInterval) {
        let item = DispatchWorkItem(qos: DispatchQoS.default, flags: .noQoS) { 
            print("当前线程为\(self.currentThread())")
        }
        let timeSince1970 = Date().timeIntervalSince1970
        let wallTime = DispatchWallTime(timespec: timespec(tv_sec: Int(timeSince1970 + time), tv_nsec: 0))
        queue.asyncAfter(wallDeadline: wallTime, execute: item)
    }
    // 全局队列优先级
    func globalQueuePriority() {
        getGlobalQueue(priority: .utility).async {
            print("优先级: utility -- 当前线程: \(self.currentThread())")
        }
        getGlobalQueue(priority: .background).async {
            print("优先级: background -- 当前线程: \(self.currentThread())")
        }
        getGlobalQueue(priority: .default).async {
            print("优先级: default -- 当前线程: \(self.currentThread())")
        }
        getGlobalQueue(priority: .userInitiated).async {
            print("优先级: userInitiated -- 当前线程: \(self.currentThread())")
        }
        getGlobalQueue(priority: .userInteractive).async {
            print("优先级: userInteractive -- 当前线程: \(self.currentThread())")
        }
        let queue = getGlobalQueue()
        queue.setTarget(queue: getGlobalQueue(priority: .utility))
        queue.async {
            print("优先级: utility -- 当前线程: \(self.currentThread())")
        }
    }
    // 为自己创建的queue设置优先级
    func setPriorityForMyQueue() {
        let queue = getGlobalQueue()
        queue.setTarget(queue: getGlobalQueue(priority: .utility))
        queue.async {
            print("优先级: utility -- 当前线程: \(self.currentThread())")
        }
    }
    // 队列与组自动关联并异步执行
    func performGroupAutoQueue() {
        print("任务组自动管理")
        let conQueue = getConcurrentQueue(queueId: "concurrentQueue")
        let group = DispatchGroup()
        for i in 1...5 {
            conQueue.async(group: group) {
                self.sleepFor(period: 1)
                print("任务\(i)执行完毕")
            }
        }
        group.notify(queue: getMainThread()) { 
            print("所有任务执行完了")
        }
        print("异步执行测试,不会阻塞当前线程")
    }
    // 队列与组手动关联并异步执行
    func performGroupManualQueue() {
        print("任务组手动管理")
        let conQueue = getConcurrentQueue(queueId: "concurrentQueue")
        let group = DispatchGroup()
        for i in 1...5 {
            group.enter()
            conQueue.async() {
                if i == 3 {
                    self.sleepFor(period: 3)
                } else {
                    self.sleepFor(period: 1)
                }
                print("任务\(i)执行完毕")
                group.leave()
            }
        }
        let result = group.wait(timeout: DispatchTime.now() + 1)
        if result == .timedOut {
            print("超时")
            return
        }
        group.notify(queue: getMainThread()) {
            print("所有任务执行完了")
        }
        print("异步执行测试,不会阻塞当前线程")
    }
    // 信号量同步锁
    func performSemaphoreLock() {
        let concurrentQueue = getConcurrentQueue(queueId: "con")
        
        let semaphore = DispatchSemaphore(value: 3)
        var tempCount = 0
        for _ in 1...10 {
            concurrentQueue.async {
                semaphore.wait()
                self.sleepFor(period: 2)
                print("\(self.currentThread())")
                tempCount += 1
                semaphore.signal()
            }
        }
        
        print("异步信号量测试")
    }
    
    /// 进阶
    // 队列的挂起和唤醒
    func suspendAndWake() {
        let queue = getConcurrentQueue(queueId: "suspdnd")
        queue.suspend()
        queue.async {
            print("唤醒了")
        }
        print("挂起五秒")
        sleepFor(period: 5)
        queue.resume()
    }
    // 任务栅栏
    func barrier() {
        let barrierQueue = getConcurrentQueue(queueId: "barrier")
        for i in 1...5 {
            barrierQueue.async {
                self.sleepFor(period: TimeInterval(i))
                print("这是i任务 - \(i) - \(self.currentThread())")
            }
        }
        let workItem = DispatchWorkItem(qos: .default, flags: [.barrier]) { 
            print("所有的i任务都在此之前,所有的j任务都在此之后 - \(self.currentThread())")
        }
        barrierQueue.async(execute: workItem)
        for j in 1...5 {
            barrierQueue.async {
                self.sleepFor(period: TimeInterval(j))
                print("这是j任务 - \(j) - \(self.currentThread())")
            }
        }
        
    }
    // 源事件 - add
    func sourceAdd() {
        let sourceQueue = getGlobalQueue()
        let source = DispatchSource.makeUserDataAddSource(queue: sourceQueue)
        
        source.setEventHandler {
            print("源中的数据和为: \(source.data)")
        }
        source.resume()
        for i in 1...6 {
            self.sleepFor(period: 1)
            source.add(data: UInt(i))
        }
    }
    // 源事件 - 定时器
    func sourceTimer() {
        let sourceQueue = getGlobalQueue()
        let source = DispatchSource.makeTimerSource(flags: .strict, queue: sourceQueue)
        var timeOut = 10
        source.scheduleRepeating(deadline: DispatchTime.now(), interval: 1)
        source.setEventHandler {
            print("每隔1秒执行一次")
            timeOut -= 1;
            if timeOut <= 0 {
                source.cancel()
            }
        }
        source.resume()
        source.setCancelHandler {
            print("执行完了")
        }
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "基础"
        } else {
            return "进阶"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell.textLabel?.text = dataSource[indexPath.section][indexPath.row]
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = dataSource[indexPath.section][indexPath.row]
            return cell
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        // 基础
        case (0, 0):
            performQueueSynchronization(queue: getSerialQueue(queueId: "serial"))
            break
        case (0, 1):
            performQueueAsynchronization(queue: getSerialQueue(queueId: "serial"))
            break
        case (0, 2):
            performQueueSynchronization(queue: getConcurrentQueue(queueId: "concurrent"))
            break
        case (0, 3):
            performQueueAsynchronization(queue: getConcurrentQueue(queueId: "concurrent"))
            break
        case (0, 4):
            deferPerform(queue: getSerialQueue(queueId: "serialDelay") ,delay: 3)
            break
        case (0, 5):
            globalQueuePriority()
            break
        case (0, 6):
            setPriorityForMyQueue()
            break
        case (0, 7):
            performGroupAutoQueue()
            break
        case (0, 8):
            performGroupManualQueue()
            break
        case (0, 9):
            performSemaphoreLock()
            break
        // 进阶
        case (1,0):
            suspendAndWake()
            break
        case (1,1):
            barrier()
            break
        case (1,2):
            sourceAdd()
            break
        case (1,3):
            sourceTimer()
            break
        case (1,4):
            break
        case (1,5):
            break
        case (1,6):
            break
        case (1,7):
            break
        case (1,8):
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
