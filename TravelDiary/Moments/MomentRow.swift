//
//  MomentRow.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 14/04/24.
//

import SwiftUI
import CoreData

struct MomentRow: View {
    let moment: Moment
    @State private var listKey = UUID()
    
    var body: some View {
        // Wrap the entire VStack in a NavigationLink
        NavigationLink(destination: MomentDetailView(moment: moment, listKey:$listKey)) {
            VStack(alignment: .leading) {
                Text(moment.title ?? "Untitled Moment")
                    .font(.headline)
                
                if let description = moment.desc, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let location = moment.location, !location.isEmpty {
                    Text("Location: \(location)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let timestamp = moment.timestamp {
                    Text("\(timestamp, formatter: itemFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                imagesView
            }
            .id(listKey)
        }
    }
    
    private var imagesView: some View {
        Group {
            if let imageData = moment.imagesData,
               let uiImagesData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imageData) as? [Data] {
                let uiImages = uiImagesData.compactMap { UIImage(data: $0) }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(uiImages, id: \.self) { uiImage in
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(4)
                        }
                    }
                }
            } else {
                Text("No images available")
                    .foregroundColor(.secondary)
            }
        }
    }

    
    private var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}


struct MomentRow_Previews: PreviewProvider {
    static var previews: some View {
        // Use the in-memory context from the preview container
        let context = PersistenceController.preview.container.viewContext
        // Create a new moment instance
        let newMoment = Moment(context: context)
        newMoment.title = "Sample Moment"
        newMoment.desc = "This is a description for a sample moment."
        newMoment.timestamp = Date()
        
        return MomentRow(moment: newMoment)
            .environment(\.managedObjectContext, context)
    }
}
