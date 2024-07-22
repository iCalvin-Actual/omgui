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
                let actingAddress = actingAddress
                try await fetchConstructor.saveFollowing(newAddresses, for: actingAddress)
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
                let actingAddress = actingAddress
                try await fetchConstructor.saveFollowing(newAddresses, for: actingAddress)
            }
        }
    }
    
    public func isFollowing(_ address: AddressName) -> Bool {
        guard !authKey.isEmpty else {
            return false
        }
        return addressFollowing.contains(address)
    }
    public func canFollow(_ address: AddressName) -> Bool {
        guard !authKey.isEmpty else {
            return false
        }
        return !addressFollowing.contains(address)
    }
    public func canUnFollow(_ address: AddressName) -> Bool {
        guard !authKey.isEmpty else {
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
    
    var applicableBlocklist: [AddressName] {
        Array(Set(globalBlocked + localBlocklist + addressBlocked))
    }
    var viewableBlocklist: [AddressName] {
        Array(Set(localBlocklist + addressBlocked))
    }
    func isBlocked(_ address: AddressName) -> Bool {
        applicableBlocklist.contains(address)
    }
    func canUnblock(_ address: AddressName) -> Bool {
        viewableBlocklist.contains(address)
    }
}
