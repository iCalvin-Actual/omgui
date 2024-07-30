//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Foundation

class BlockListDataFetcher: ListDataFetcher<AddressModel> {
    override var title: String {
        "blocked"
    }
    
    let addressBlocklistFetcher: AddressBlockListDataFetcher?
    let globalBlocklistFetcher: AddressBlockListDataFetcher
    let localBloclistFetcher: LocalBlockListDataFetcher
    
    override var loading: Bool {
        get {
            globalBlocklistFetcher.loading || localBloclistFetcher.loading || addressBlocklistFetcher?.loading ?? false
        }
        set { }
    }
    override var loaded: Bool {
        get {
            let stableLoaded = globalBlocklistFetcher.loaded && localBloclistFetcher.loaded
            let localLoaded = addressBlocklistFetcher?.loaded ?? true
            return stableLoaded && localLoaded
        }
        set { }
    }
    
    override var results: [AddressModel] {
        get {
            Array(Set((addressBlocklistFetcher?.results ?? []) + localBloclistFetcher.results))
        }
        set { }
    }
    
    init(
        globalFetcher: AddressBlockListDataFetcher,
        localFetcher: LocalBlockListDataFetcher,
        addressFetcher: AddressBlockListDataFetcher? = nil,
        interface: DataInterface
    ) {
        self.addressBlocklistFetcher = addressFetcher
        self.globalBlocklistFetcher = globalFetcher
        self.localBloclistFetcher = localFetcher
        
        super.init(interface: interface)
        
        globalBlocklistFetcher.objectWillChange.sink { _ in
            self.updateList()
        }.store(in: &requests)
        
        localBloclistFetcher.objectWillChange.sink { _ in
            self.updateList()
        }.store(in: &requests)
        
        addressBlocklistFetcher?.objectWillChange.sink { _ in
            self.updateList()
        }.store(in: &requests)
    }
    
    func updateList() {
        let local = localBloclistFetcher.results
        let address = addressBlocklistFetcher?.results ?? []
        self.results = Array(Set(local + address))
        self.threadSafeSendUpdate()
    }
    
    func block(_ address: AddressName, credential: APICredential?) {
        if addressBlocklistFetcher != nil, let credential = credential {
            addressBlocklistFetcher?.block(address, credential: credential)
        }
        localBloclistFetcher.insert(address)
    }
    
    func insertItems(_ newItems: [AddressModel]) {
        let toAdd = newItems.filter { !results.contains($0) }
        self.results.append(contentsOf: toAdd)
        self.fetchFinished()
    }
    
    override func perform() async {
        await super.perform()
        await globalBlocklistFetcher.updateIfNeeded()
        await localBloclistFetcher.updateIfNeeded()
        await addressBlocklistFetcher?.updateIfNeeded()
    }
}
