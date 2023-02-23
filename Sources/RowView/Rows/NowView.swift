import SwiftUI

@available(iOS 16.1, *)
struct NowGardenView: View {
    let model: NowListing
    
    @Environment(\.isSearching) var isSearching
    
    var narrow: Bool {
        isSearching
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(value: NavigationDetailView.profile(model.addressName)) { 
                Text(model.listTitle)
                    .font(.title3)
                    .bold()
                    .fontDesign(.serif)
                    .padding([.horizontal, .bottom], 4)
            }
            
            VStack(alignment: .leading) {
                Text(model.listSubtitle)
                    .font(.body)
                    .fontDesign(.monospaced)
                    .padding(.vertical, !narrow ? 8 : 0)
                    .padding(.bottom, 4)
                    .padding(.trailing, 4)
                
                HStack(alignment: .bottom) {
                    Spacer()
                    if !narrow, let caption = model.listCaption {
                        Text(caption)
                            .font(.subheadline)
                            .bold(false)
                    }              
                }
            }
            .padding()
            .background(Color.lolRandom(model))
            .cornerRadius(12, antialiased: true)
        }
    }
}

extension NowListing {
    static var calvin: NowListing {
        .init(
            owner: "calvin",
            url: "https://cbc.gay/now",
            updated: .init(timeIntervalSince1970: 0)
        )
    }
    static var app: NowListing {
        .init(
            owner: "app",
            url: "https://app.omg.lol",
            updated: .init()
        )
    }
    static var merlin: NowListing {
        .init(
            owner: "hotdogsladies",
            url: "https://hotdogsladies.omg.lol",
            updated: .init()
        )
    }
}
