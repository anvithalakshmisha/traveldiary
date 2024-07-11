//
//  EditMomentView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 26/04/24.
//

import SwiftUI

import SwiftUI
import CoreData
import PhotosUI

struct EditMomentView: View {
    @ObservedObject var moment: Moment
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String
    @State private var description: String
    @State private var images: [UIImage] = []
    @State private var isImagePickerPresented = false
    @State private var alertMessage: AlertMessage?
    @Binding var listKey: UUID

    init(moment: Moment, listKey: Binding<UUID>) {
        self._listKey = listKey
        self.moment = moment
        _title = State(initialValue: moment.title ?? "")
        _description = State(initialValue: moment.desc ?? "")
        if let imageDataArray = moment.imagesData,
           let imageDatas = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imageDataArray) as? [Data] {
            _images = State(initialValue: imageDatas.compactMap { UIImage(data: $0) })
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Moment Details")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 200)
                }

                Section(header: Text("Images")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(images, id: \.self) { img in
                                Image(uiImage: img)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                self.isImagePickerPresented = true
                            }) {
                                Image(systemName: "plus")
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Moment")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveChanges()
            })
            .sheet(isPresented: $isImagePickerPresented) {
                PhotoPicker(images: $images)
            }
            .alert(item: $alertMessage) { alertMessage in
                Alert(title: Text(alertMessage.title), message: Text(alertMessage.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveChanges() {
        moment.title = title
        moment.desc = description

        let imageDataArray = images.map { $0.jpegData(compressionQuality: 1.0) }
        let imagesData = try? NSKeyedArchiver.archivedData(withRootObject: imageDataArray, requiringSecureCoding: false)

        moment.imagesData = imagesData
        moment.timestamp = Date()

        do {
            try viewContext.save()
            listKey = UUID()
            presentationMode.wrappedValue.dismiss()
        } catch {
            alertMessage = AlertMessage(title: "Error", message: "There was an error saving the moment: \(error.localizedDescription)")
        }
    }
    
    struct PhotoPicker: UIViewControllerRepresentable {
        @Binding var images: [UIImage]
        
        func makeUIViewController(context: Context) -> PHPickerViewController {
            var config = PHPickerConfiguration()
            config.selectionLimit = 0 // 0 means no limit
            config.filter = .images
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, PHPickerViewControllerDelegate {
            var parent: PhotoPicker
            
            init(_ parent: PhotoPicker) {
                self.parent = parent
            }
            
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                picker.dismiss(animated: true)
                for result in results {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                                        print("Selected image: \(image), size: \(image.size)")
                            }
                        } else if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    struct AlertMessage: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
}

// The preview provider for EditMomentView, if needed.
//struct EditMomentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = PersistenceController.preview.container.viewContext
//        let newMoment = Moment(context: context)
//        newMoment.title = "Sample Moment"
//        newMoment.desc = "This is a description for a sample moment."
//        newMoment.timestamp = Date()
//
//        return EditMomentView(moment: newMoment)
//            .environment(\.managedObjectContext, context)
//    }
//}

