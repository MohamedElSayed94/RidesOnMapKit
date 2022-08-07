//
//  NetworkMonitor.swift
//  TIERMobilityTask
//
//  Created by Mohamed Elsayed on 06/08/2022.
//

import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    public private(set) var  isConnected: Bool = false
    
    public private(set) var connectionType: ConnectionType = .unknown
    
    init() {
        
        
    }
    
    public enum ConnectionType {
        case cellular
        case wifi
        case ethernet
        case unknown
    }
    
    public func startMonitoring() {
        
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied{
                self?.isConnected = true
            }else{
                self?.isConnected = false
            }
            
            self?.getConnectionType(path)
            NotificationCenter.default.post(name: NSNotification.Name("connectionType"),
                                            object: nil)
        }
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}
