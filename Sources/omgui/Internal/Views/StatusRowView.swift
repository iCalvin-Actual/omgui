//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI
import Ink

@MainActor
struct StatusRowView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(\.viewContext)
    var context: ViewContext
    
    @State
    var showURLs: Bool = false
    @State
    var presentUrl: URL? = nil
    
    @State
    var destination: NavigationDestination? = nil
    
    @GestureState
    private var zoom = 1.0
    
    let model: StatusModel
    
    init(model: StatusModel) {
        self.model = model
    }
    
    init(_ response: StatusResponse) {
        self.init(model: .init(response))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            buttonIfNeeded
            
            rowBody
                .padding(.bottom, 2)
                .asCard(backgroundColor: .lolRandom(model.displayEmoji), radius: 6)
        
            if let caption = model.listCaption {
                Text(caption)
                    .frame(alignment: .trailing)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .sheet(item: $destination, content: { destination in
            NavigationStack {
                sceneModel.destinationConstructor.destination(destination)
            }
        })
        .confirmationDialog("Open Image", isPresented: $showURLs, actions: {
            ForEach(model.imageLinks) { link in
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
    var rowBody: some View {
        Group {
            /*
             This was tricky to set up
             so I'm leaving it here
             
//                    Text(model.displayEmoji)
//                        .font(.system(size: 44))
//                    + Text(" ").font(.largeTitle) +
             */
            appropriateMarkdown
                .font(.system(.body))
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .environment(\.colorScheme, .light)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black)
        }
        .lineLimit(context == .column ? 5 : nil)
        .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    var appropriateMarkdown: some View {
        switch context {
        case .detail:
            MarkdownContentView(source: model, content: model.status)
        default:
            Markdown(model.status)
        }
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
                    AddressNameView(model.address, font: .title3)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(3)
                        .foregroundColor(.black)
                        .padding(.vertical, 4)
                }
                .padding(.horizontal, 2)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
