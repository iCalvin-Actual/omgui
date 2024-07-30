//
//  DataFetchers.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine
import Foundation

@MainActor
class URLContentDataFetcher: DataFetcher {
    let url: URL
    
    @Published
    var html: String?
    
    init(url: URL, html: String? = nil, interface: DataInterface) {
        self.url = url
        self.html = html
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        guard url.scheme?.contains("http") ?? false else {
            self.fetchFinished()
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
          .map(\.data)
          .eraseToAnyPublisher()
          .receive(on: DispatchQueue.main)
          .sink(receiveCompletion: { _ in }) { [weak self] newValue in
              self?.html = String(data: newValue, encoding: .utf8)
              self?.fetchFinished()
          }
          .store(in: &requests)
    }
}

@MainActor
class AddressIconDataFetcher: DataFetcher {
    let address: AddressName
    
    @Published
    var iconData: Data?
    
    init(address: AddressName, interface: DataInterface) {
        self.address = address
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        guard let url = address.addressIconURL else {
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .map{ $0.data }
            .sink { _ in } receiveValue: { [weak self] value in
                self?.iconData = value
                self?.fetchFinished()
            }
            .store(in: &requests)
    }
}
