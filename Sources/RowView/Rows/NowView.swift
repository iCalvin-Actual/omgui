import SwiftUI

@available(iOS 16.1, *)
struct NowGardenView: View {
    let model: NowModel
    
    @Environment(\.isSearching) var isSearching
    
    var narrow: Bool {
        isSearching
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !narrow {
                Spacer()
            }
            Text("")
                .font(.title)
                .padding(.vertical, !narrow ? 8 : 0)
                .padding(.bottom, 4)
                .padding(.trailing, 4)
            
            
            HStack(alignment: .bottom) {
                if !narrow {
                    Text("")
                        .font(.headline)
                    Spacer()
                    Text("Updated")
                        .font(.subheadline)
                        .bold(false)
                } else {
                    Spacer()
                }
            }
            .padding(.trailing)
        }
        .padding(.vertical)
        .padding(.leading, 32)
        .background(Color.yellow)
        .cornerRadius(24)
        .fontDesign(.serif)
        .bold()
    }
}

extension NowModel {
    static var calvin: NowModel {
        .init(
            owner: "calvin",
            url: "https://cbc.gay/now",
            updated: .init(timeIntervalSince1970: 0)
        )
    }
    static var app: NowModel {
        .init(
            owner: "app",
            url: "https://app.omg.lol",
            updated: .init()
        )
    }
    static var merlin: NowModel {
        .init(
            owner: "hotdogsladies",
            url: "https://hotdogsladies.omg.lol",
            updated: .init()
        )
    }
}
