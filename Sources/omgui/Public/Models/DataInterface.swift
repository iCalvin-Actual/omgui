//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

public protocol DataInterface: Sendable {
    
    // MARK: General Service 
    
    func fetchServiceInfo()
    async throws -> ServiceInfoModel
    
    func fetchThemes() 
    async throws -> [ThemeModel]
    
    func fetchAddressDirectory()
    async throws -> [AddressName]
    
    func fetchNowGarden()
    async throws -> [NowListing]
    
    func fetchStatusLog()
    async throws -> [StatusModel]
    
    func fetchCompleteStatusLog()
    async throws -> [StatusModel]
    
    // MARK: Address Content
    
    func fetchAddressAvailability(
        _ address: AddressName
    )
    async throws -> AddressAvailabilityModel
    
    func fetchAddressInfo(
        _ name: AddressName
    )
    async throws -> AddressModel
    
    func fetchAddressBio(
        _ name: AddressName
    )
    async throws -> AddressSummaryModel
    
    func fetchAddressProfile(
        _ name: AddressName,
        credential: APICredential?
    )
    async throws -> AddressProfile?
    
    func fetchAddressNow(
        _ name: AddressName
    )
    async throws -> NowModel?
    
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
    
    func fetchAddressStatuses(
        addresses: [AddressName]
    )
    async throws -> [StatusModel]
    
    func fetchAddressStatus(
        _ id: String,
        from address: AddressName
    )
    async throws -> StatusModel?
    
    // MARK: Account
    
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
    
    func fetchAccountAddresses(
        _ credential: String
    )
    async throws -> [AddressName]
    
    func fetchAccountInfo(
        _ address: AddressName,
        credential: APICredential
    )
    async throws -> AccountInfoModel?
    
    // MARK: Deleting
    
    func deletePaste(
        _ id: String,
        from address: AddressName,
        credential: APICredential
    )
    async throws
    
    func deletePURL(
        _ id: String,
        from address: AddressName,
        credential: APICredential
    )
    async throws
    
    func deleteAddressStatus(
        _ draft: StatusModel.Draft,
        from address: AddressName,
        credential: APICredential
    )
    async throws -> StatusModel?
    
    // MARK: Posting
    
    func saveAddressProfile(
        _ name: AddressName,
        content: String,
        credential: APICredential
    )
    async throws -> AddressProfile?
    
    func saveAddressNow(
        _ name: AddressName,
        content: String,
        credential: APICredential
    )
    async throws -> NowModel?
    
    func savePURL(
        _ draft: PURLModel.Draft,
        to address: AddressName,
        credential: APICredential
    )
    async throws -> PURLModel?
    
    func savePaste(
        _ draft: PasteModel.Draft,
        to address: AddressName,
        credential: APICredential
    )
    async throws -> PasteModel?
    
    func saveStatusDraft(
        _ draft: StatusModel.Draft,
        to address: AddressName,
        credential: APICredential
    )
    async throws -> StatusModel?
    
}
