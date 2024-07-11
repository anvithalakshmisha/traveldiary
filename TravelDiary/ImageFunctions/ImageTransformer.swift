//
//  ImageTransformer.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 14/04/24.
//

import UIKit
import CoreData

class ImageTransformer: ValueTransformer {
    
    // This tells the transformer what type of data it should be expecting to receive and return.
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    // This indicates whether the transformer allows reverse transformations.
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    // This method takes an array of UIImage, converts each image to Data, and returns an NSData object containing an array of Data.
    override func transformedValue(_ value: Any?) -> Any? {
        guard let images = value as? [UIImage] else { return nil }
        do {
            let imageDataArray = try NSKeyedArchiver.archivedData(withRootObject: images, requiringSecureCoding: true)
            return imageDataArray
        } catch {
            return nil
        }
    }
    
    // This method takes an NSData object, unarchives it to an array of Data, and converts each Data object back into a UIImage.
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let imageDataArray = value as? Data else { return nil }
        do {
            let images = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self , from: imageDataArray)
            return images
        } catch {
            return nil
        }
    }
    
}

