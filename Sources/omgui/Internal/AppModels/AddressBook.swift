//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/18/23.
//

import Combine
import SwiftData
import SwiftUI

extension SceneModel {
    var addressFollowing: [AddressName] {
        get {
            let predicate = #Predicate<AddressInfoModel> {
                $0.owner == actingAddress
            }
            let fetchDescriptor = FetchDescriptor<AddressInfoModel>(predicate: predicate)
            do {
                guard let model: AddressInfoModel = try context.fetch(fetchDescriptor).first else {
                    return []
                }
                return model.following
            } catch {
                print("LOG Failed to fetch following")
                return []
            }
        }
        set {
            let newAddresses = newValue.filter { !$0.isEmpty }
            Task { [weak self] in
                guard let self else { return }
                try await saveFollowing(newAddresses, for: actingAddress)
            }
        }
    }
    var addressBlocked: [AddressName] {
        get {
            let predicate = #Predicate<AddressInfoModel> {
                $0.owner == actingAddress
            }
            let fetchDescriptor = FetchDescriptor<AddressInfoModel>(predicate: predicate)
            do {
                guard let model: AddressInfoModel = try context.fetch(fetchDescriptor).first else {
                    return []
                }
                return model.blocked
            } catch {
                print("LOG Failed to fetch following")
                return []
            }
        }
        set {
            let newAddresses = newValue.filter { !$0.isEmpty }
            Task { [weak self] in
                guard let self else { return }
                try await saveFollowing(newAddresses, for: actingAddress)
            }
        }
    }
    
    public func isFollowing(_ address: AddressName) -> Bool {
        guard accountModel.signedIn else {
            return false
        }
        return addressFollowing.contains(address)
    }
    public func canFollow(_ address: AddressName) -> Bool {
        guard accountModel.signedIn else {
            return false
        }
        return !addressFollowing.contains(address)
    }
    public func canUnFollow(_ address: AddressName) -> Bool {
        guard accountModel.signedIn else {
            return false
        }
        return addressFollowing.contains(address)
    }
    public func follow(_ address: AddressName) {
        addressFollowing.append(address)
    }
    public func unFollow(_ address: AddressName) {
        addressFollowing.removeAll(where: { $0 == address })
    }
    
    private var globalBlocked: [AddressName] {
        accountModel.globalBlocked
    }
    private var localBlocked: [AddressName] {
        accountModel.localBlocked
    }
    
    var applicableBlocklist: [AddressName] {
        Array(Set(globalBlocked + localBlocked + addressBlocked))
    }
    var viewableBlocklist: [AddressName] {
        Array(Set(localBlocked + addressBlocked))
    }
    func isBlocked(_ address: AddressName) -> Bool {
        applicableBlocklist.contains(address)
    }
    func canUnblock(_ address: AddressName) -> Bool {
        viewableBlocklist.contains(address)
    }
    func block(_ address: AddressName) {
        guard accountModel.signedIn else {
            accountModel.block(address)
            return
        }
        addressBlocked.append(address)
    }
    func unblock(_ address: AddressName) {
        guard accountModel.signedIn else {
            accountModel.unblock(address)
            return
        }
        addressBlocked.removeAll(where: { $0 == address })
    }
    
    var pinned: [AddressName] {
        accountModel.pinnedAddresses
    }
    
    var myAddresses: [AddressName] {
        accountModel.myAddresses
    }
    
    func isPinned(_ address: AddressName) -> Bool {
        pinned.contains(address)
    }
    func pin(_ address: AddressName) {
        accountModel.pin(address)
    }
    func removePin(_ address: AddressName) {
        accountModel.removePin(address)
    }
}
