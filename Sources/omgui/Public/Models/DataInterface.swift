//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

public protocol DataInterface: Sendable {
    
    func authURL()
    -> URL?
    
    func fetchThemes() 
    async throws -> [ThemeModel]
    
    @MainActor
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
    async throws -> [PURLModel]
    
    func fetchPURL(
        _ id: String,
        from address: AddressName,
        credential: APICredential?
    )
    async throws -> PURLModel?
    
    func fetchPURLContent(
        _ id: String,
        from address: AddressName,
        credential: APICredential?
    )
    async throws -> String?
    
    func savePURL(
        _ draft: PURLModel.Draft,
        to address: AddressName,
        credential: APICredential
    )
    async throws -> PURLModel?
    
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
    
    func savePaste(
        _ draft: PasteModel.Draft,
        to address: AddressName,
        credential: APICredential
    )
    async throws -> PasteModel?
    
    func fetchStatusLog()
    async throws -> [StatusModel]
    
    func fetchAddressStatuses(
        addresses: [AddressName]
    )
    async throws -> [StatusModel]
    
    func fetchAddressStatus(
        _ id: String,
        from address: AddressName
    )
    async throws -> StatusModel?
    
    func deleteAddressStatus(
        _ draft: StatusModel.Draft,
        from address: AddressName,
        credential: APICredential
    )
    async throws -> StatusModel?
    
    func saveStatusDraft(
        _ draft: StatusModel.Draft,
        to address: AddressName,
        credential: APICredential
    )
    async throws -> StatusModel?
    
    func fetchAddressBio(
        _ name: AddressName
    )
    async throws -> AddressBioModel
    
}
