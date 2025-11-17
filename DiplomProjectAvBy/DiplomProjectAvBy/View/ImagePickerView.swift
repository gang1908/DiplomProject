//
//  ImagePickerView.swift
//  DiplomProjectAvBy
//
//  Created by Ангелина Голубовская on 16.10.25.
//

//import SwiftUI
//
//// Обертка для UIImagePickerController
//struct ImagePickerView: UIViewControllerRepresentable {
//    let onImagesSelected: ([UIImage]) -> Void
//    @Environment(\.dismiss) private var dismiss
//    
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        picker.allowsEditing = false
//        picker.sourceType = .photoLibrary
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        let parent: ImagePickerView
//        
//        init(_ parent: ImagePickerView) {
//            self.parent = parent
//        }
//        
//        func imagePickerController(_ picker: UIImagePickerController,
//                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let image = info[.originalImage] as? UIImage {
//                parent.onImagesSelected([image])
//            }
//            parent.dismiss()
//        }
//        
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            parent.dismiss()
//        }
//    }
//}
