//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

public protocol DataInterface {
    
    func authURL() -> URL?
    
    func fetchAccessToken(
        authCode: String,
        clientID: String,
        clientSecret: String,
        redirect: String
    )
    async throws -> String?
    
    func fetchServiceInfo()
    async throws -> ServiceInfoModel
    
    func fetchAddressDirectory()
    async throws -> [AddressName]
    
    func fetchAccountAddresses(
        _ credential: String
    )
    async throws -> [AddressName]
    
    func fetchNowGarden()
    async throws -> [NowListing]
    
    func fetchAddressProfile(
        _ name: AddressName
    )
    async throws -> AddressProfile?
    
    func fetchAddressInfo(
        _ name: AddressName
    )
    async throws -> AddressModel
    
    func fetchAddressNow(
        _ name: AddressName
    )
    async throws -> NowModel?
    
    func fetchAddressPURLs(
        _ name: AddressName
    )
    async throws -> [PURLModel]
    
    func fetchAddressPastes(
        _ name: AddressName
    )
    async throws -> [PasteModel]
    
    func fetchPaste(
        _ id: String,
        from address: AddressName
    )
    async throws -> PasteModel?
    
    func fetchStatusLog()
    async throws -> [StatusModel]
    
    func fetchAddressStatuses(
        addresses: [AddressName]
    )
    async throws -> [StatusModel]
    
    func fetchAddressBio(
        _ name: AddressName
    )
    async throws -> AddressBioModel
    
}
