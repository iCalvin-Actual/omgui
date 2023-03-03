import SwiftUI

@available(iOS 16.1, *)
struct AddressView: View {
    
    @EnvironmentObject
    var appModel: AppModel
    
    let model: AddressModel
    
    @Environment(\.isSearching) var isSearching
    
    var narrow: Bool {
        isSearching
    }
    
    init(model: AddressModel) {
        self.model = model
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !narrow {
                Spacer()
            }
            Text(model.addressName.addressDisplayString)
                .font(.title)
                .bold()
                .padding(.vertical, !narrow ? 8 : 0)
                .padding(.bottom, 4)
                .padding(.trailing, 4)
                .fontDesign(.serif)
            
            
            HStack(alignment: .bottom) {
                if !narrow {
                    Spacer()
                    if let registered = model.registered {
                        Text("Since \(DateFormatter.monthYear.string(from: registered))")
                            .font(.subheadline)
                            .bold(false)
                    }
                } else {
                    Spacer()
                }
            }
            .padding(.trailing)
        }
        .foregroundColor(.black)
        .contextMenu {
            if appModel.isPinned(model.addressName) {
                Button(action: {
                    appModel.pin(model.addressName)
                }, label: {
                    Label("Pin \(model.addressName.addressDisplayString)", systemImage: "pin")
                })
            } else {
                Button(action: {
                    appModel.removePin(model.addressName)
                }, label: {
                    Label("Un-Pin \(model.addressName.addressDisplayString)", systemImage: "pin.slash")
                })
            }
        }
        .padding(.vertical)
        .padding(.leading, 32)
        .background(Color.lolYellow)
        .cornerRadius(24)
    }
}
