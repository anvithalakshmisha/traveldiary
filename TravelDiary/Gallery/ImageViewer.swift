//
//  ImageViewer.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 24/04/24.
//

import SwiftUI

struct ImageViewer: View {
    var image: UIImage
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)
            
            Button(action: {
                // Dismiss the sheet when the button is tapped
            }) {
                Image(systemName: "xmark.circle")
                    .padding()
                    .foregroundColor(.white)
            }
        }
    }
}

//#Preview {
//    ImageViewer()
//}
