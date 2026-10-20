//
//  RecipeImageView.swift
//  Romulo_Midterm
//
//  Created by Mac-LAB on 10/20/26.
//

import SwiftUI
import UIKit

struct RecipeImageView: View {
    var imageData: Data?
    var symbol: String = "fork.knife.circle.fill"
    var width: CGFloat?
    var height: CGFloat = 44

    var body: some View {
        Color.orange.opacity(0.15)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? CGFloat.infinity : nil)
            .overlay {
                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: symbol)
                        .resizable()
                        .scaledToFit()
                        .padding(height * 0.2)
                        .foregroundStyle(.orange)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
