//
//  MomentDetailView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 26/04/24.
//

import SwiftUI
import CoreData

struct MomentDetailView: View {
    @ObservedObject var moment: Moment // Use @ObservedObject
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingDetailView = false
    @State private var selectedImage: UIImage?
    @State private var isEditing = false
    @Binding var listKey: UUID
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4) // Adjust the count as needed for your design
    
    init(moment: Moment, listKey: Binding<UUID>) {
            self._moment = ObservedObject(wrappedValue: moment)
            self._listKey = listKey
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(moment.title ?? "Untitled Moment")
                .font(.title)
                .fontWeight(.bold)
            
            // Description
            if let description = moment.desc, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Images
            if let imageData = moment.imagesData,
               let uiImagesData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imageData) as? [Data],
               !uiImagesData.isEmpty {
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(uiImagesData, id: \.self) { data in
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
                                .padding(10)
                                .onTapGesture {
                                    // When an image is tapped, update the selected image and show the detail view
                                    self.selectedImage = uiImage
                                    self.isShowingDetailView = true
                                }
                        }
                        
                    }
                }
            } else {
                Text("No images available")
                    .foregroundColor(.secondary)
            }
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $isShowingDetailView) {
            // This will present the selected image in a detail view
            if let selectedImage = selectedImage {
                ImageViewer(image: selectedImage)
            }
        }
        .padding()
        .navigationBarItems(trailing:
                                Button(action: {
            isEditing = true
        }) {
            Image(systemName: "pencil")
        }
        )
        .navigationBarTitle("Moment Detail", displayMode: .inline)
        .sheet(isPresented: $isEditing) {
            EditMomentView(moment: moment, listKey: $listKey)
                .environment(\.managedObjectContext, moment.managedObjectContext!)
        }
        Spacer()
    }
}

// Preview of MomentDetailView
//struct MomentDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = PersistenceController.preview.container.viewContext
//        let newMoment = Moment(context: context)
//        newMoment.title = "Sample Moment"
//        newMoment.desc = "This is a description for a sample moment."
//        newMoment.timestamp = Date()
//
//        return NavigationView {
//            MomentDetailView(moment: newMoment)
//                .environment(\.managedObjectContext, context)
//        }
//    }
//}
