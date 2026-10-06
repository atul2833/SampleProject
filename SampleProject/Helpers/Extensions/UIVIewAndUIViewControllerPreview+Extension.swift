//
//  UIVIewAndUIViewControllerPreview+Extension.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 14/01/2024.
//


import UIKit
import SwiftUI

extension UIViewController {
    // enable preview for UIKit
    // source: https://fluffy.es/xcode-previews-uikit/
    @available(iOS 13, *)
    private struct Preview: UIViewControllerRepresentable {
        // this variable is used for injecting the current view controller
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            //
        }
    }
    
    @available(iOS 13, *)
    func showPreview() -> some View {
        Preview(viewController: self)
    }
}

/////////////////////////////////////////////////////////////////////////

//@available(iOS 13, *)
//struct ViewController_Preview: PreviewProvider {
//    static var previews: some View {
//        // view controller using programmatic UI
//        ViewController().showPreview()
//    }
//}


extension UIView {
    // enable preview for UIKit
    // source: https://dev.to/gualtierofr/preview-uikit-views-in-xcode-3543
    @available(iOS 13, *)
    private struct Preview: UIViewRepresentable {
        typealias UIViewType = UIView
        let view: UIView
        func makeUIView(context: Context) -> UIView {
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            //
        }
    }
    
    @available(iOS 13, *)
    func showPreview() -> some View {
        // inject self (the current UIView) for the preview
        Preview(view: self)
    }
}

//
//@available(iOS 13, *)
//struct HeaderView_Preview: PreviewProvider {
//    static var previews: some View {
//        // view controller using programmatic UI
//        InternationalRemmittanceCollectionViewCell().showPreview()
//    }
//}
