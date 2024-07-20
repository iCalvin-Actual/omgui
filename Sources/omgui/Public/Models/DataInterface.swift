//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation
import SwiftData

public protocol DataInterface: Sendable {
    
    func authURL()
    -> URL?
    
    @MainActor
    func fetchAccessToken(
        authCode: String,
        clientID: String,
        clientSecret: String,
        redirect: String
    )
    async throws -> String?
    
    func fetchThemes() 
    async throws -> [ThemeModel]
    
    func fetchServiceInfo()
    async throws -> ServiceInfoModel
    
    func fetchAddressDirectory()
    async throws -> [AddressName]
    
    func fetchAccountAddresses(
        _ credential: String
    )
    async throws -> [AddressName]
    
    func fetchAccountInfo(
        _ address: AddressName,
        credential: APICredential
    )
    async throws -> AccountInfoModel?
    
    func fetchNowGarden()
    async throws -> [NowListing]
    
    func fetchAddressProfile(
        _ name: AddressName,
        credential: APICredential?
    )
    async throws -> AddressProfile?
    
    func saveAddressProfile(
        _ name: AddressName,
        content: String,
        credential: APICredential
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
    
    func saveAddressNow(
        _ name: AddressName,
        content: String,
        credential: APICredential
    )
    async throws -> NowModel?
    
    func fetchAddressPURLs(
        _ name: AddressName,
        credential: APICredential?
    )
    async throws -> [PURLResponse]
    
    func fetchPURL(
        _ id: String,
        from address: AddressName,
        credential: APICredential?
    )
    async throws -> PURLResponse?
    
    func fetchPURLContent(
        _ id: String,
        from address: AddressName,
        credential: APICredential?
    )
    async throws -> String?
    
    func deletePURL(
        _ id: String,
        from address: AddressName,
        credential: APICredential
    )
    async throws
    
    func savePURL(
        _ draft: PURLResponse.Draft,
        to address: AddressName,
        credential: APICredential
    )
    async throws -> PURLResponse?
    
    func fetchAddressPastes(
        _ name: AddressName,
        credential: APICredential?
    )
    async throws -> [PasteModel]
    
    func fetchPaste(
        _ id: String,
        from address: AddressName,
        credential: APICredential?
    )
    async throws -> PasteModel?
    
    func deletePaste(
        _ id: String,
        from address: AddressName,
        credential: APICredential
    )
    async throws
    
    func savePaste(
        _ draft: PasteModel.Draft,
        to address: AddressName,
        credential: APICredential
    )
    async throws -> PasteModel?
    
    func fetchStatusLog()
    async throws -> [StatusResponse]
    
    func fetchAddressStatuses(
        addresses: [AddressName]
    )
    async throws -> [StatusResponse]
    
    func fetchAddressStatus(
        _ id: String,
        from address: AddressName
    )
    async throws -> StatusResponse?
    
    func deleteAddressStatus(
        _ draft: StatusResponse.Draft,
        from address: AddressName,
        credential: APICredential
    )
    async throws -> StatusResponse?
    
    func saveStatusDraft(
        _ draft: StatusResponse.Draft,
        to address: AddressName,
        credential: APICredential
    )
    async throws -> StatusResponse?
    
    func fetchAddressBio(
        _ name: AddressName
    )
    async throws -> AddressBioResponse
}
