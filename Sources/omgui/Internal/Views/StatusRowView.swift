//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI
import Ink

struct StatusRowView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    @State
    var showURLs: Bool = false
    @State
    var presentUrl: URL?
    
    @State
    var destination: NavigationDestination?
    @GestureState 
    private var zoom = 1.0
    
    let model: StatusModel
    let context: ViewContext
    
    var imageLinks: [SharePacket] {
        func extractImageNamesAndURLs(from markdown: String) -> [(name: String, url: URL)] {
            var results = [(name: String, url: URL)]()
            
            do {
                let regex = try NSRegularExpression(pattern: "!\\[(.*?)\\]\\(([^)]+)\\)", options: [])
                let nsString = NSString(string: markdown)
                let matches = regex.matches(in: markdown, options: [], range: NSRange(location: 0, length: nsString.length))
                
                for set in matches.enumerated() {
                    let match = set.element
                    guard match.numberOfRanges == 3 else { continue }
                    let nameRange = match.range(at: 1)
                    let urlRange = match.range(at: 2)
                    let matchingName = nsString.substring(with: nameRange)
                    let name: String
                    if matchingName.isEmpty {
                        name = "Image \(set.offset + 1)"
                    } else {
                        name = matchingName
                    }
                    let urlString = nsString.substring(with: urlRange)
                    guard let url = URL(string: urlString) else {
                        continue
                    }
                    results.append((name, url))
                }
            } catch {
                print("Error while processing regex: \(error)")
            }
            
            return results
        }
        return extractImageNamesAndURLs(from: model.status).map({ SharePacket(name: $0.name, content: $0.url) })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            buttonIfNeeded
            
            VStack(alignment: .trailing, spacing: 1) {
                tappableIfNeeded
                
                if let caption = model.listCaption {
                    Text(caption)
                        .font(.caption2)
                        .foregroundStyle(Color.gray)
                }
            }
            .asCard(color: .lolRandom(model.displayEmoji), radius: 6)
            .padding(.bottom, 2)
            
            HStack(alignment: .bottom) {
                if let text = model.link?.absoluteString {
                    Button(action: {
                        print("Show Link")
                    }, label: {
                        Label(text, systemImage: "link")
                    })
                }
                Spacer()
                    .frame(height: 4)
            }
        }
        .sheet(item: $destination, content: { destination in
            NavigationStack {
                sceneModel.destinationConstructor.destination(destination)
            }
        })
        .confirmationDialog("Open Image", isPresented: $showURLs, actions: {
            ForEach(imageLinks) { link in
                Button {
                    presentUrl = link.content
                } label: {
                    Text(link.name)
                }
            }
        })
        .sheet(item: $presentUrl) { url in
            AsyncImage(url: url) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(zoom)
                    .gesture(
                        MagnifyGesture()
                            .updating($zoom) { value, gestureState, transaction in
                                gestureState = value.magnification
                            }
                    )
            } placeholder: {
                ThemedTextView(text: "Loading image...")
            }
        }
    }
    
    @ViewBuilder
    var tappableIfNeeded: some View {
        if context != .column, !imageLinks.isEmpty {
            Button {
                showURLs.toggle()
            } label: {
                tappableBody
            }
            .buttonStyle(.plain)
        } else {
            tappableBody
        }
    }
    
    @ViewBuilder
    var tappableBody: some View {
        Group {
            /*
             This was tricky to set up
             so I'm leaving it here
             
//                    Text(model.displayEmoji)
//                        .font(.system(size: 44))
//                    + Text(" ").font(.largeTitle) +
             */
            Markdown(model.status)
                .font(.system(.headline))
                .fontWeight(.medium)
                .fontDesign(.serif)
                .environment(\.colorScheme, .light)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black)
        }
        .lineLimit(context == .column ? 5 : nil)
        .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    var buttonIfNeeded: some View {
        if context == .detail  {
            Button {
                destination = .address(model.address)
            } label: {
                headerContent
            }
        } else {
            headerContent
        }
    }
    
    @ViewBuilder
    var headerContent: some View {
        HStack(alignment: .bottom) {
            if context != .profile {
                Menu {
                    AddressModel(name: model.address).contextMenu(in: sceneModel)
                } label: {
                    AsyncImage(url: model.address.addressIconURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.lolRandom(model.address)
                    }
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.vertical, 4)
                }
            }
            HStack(alignment: .lastTextBaseline) {
                Text(model.displayEmoji)
                    .font(.system(size: 42))
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    if context != .profile {
                        AddressNameView(model.address, font: .title3)
                            .foregroundColor(.black)
                            .padding([.horizontal, .bottom], 4)
                    }
                }
            }
        }
    }
}
