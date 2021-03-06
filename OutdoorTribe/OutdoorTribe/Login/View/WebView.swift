//
//  WebView.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/7/12.
//

import Foundation
import WebKit

class WebView: UIViewController {
    var webView = WKWebView()
    let reportButton = UIButton()
    var url = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: URL(string: url)!))
        webView.allowsBackForwardNavigationGestures = true
        layoutWebView()
        addDragFloatBtn()
    }
}

extension WebView {
    func layoutWebView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    private func addDragFloatBtn() {
        reportButton.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: 70, width: 60, height: 60)

        reportButton.layer.cornerRadius = 30.0
        view.addSubview(reportButton)
        reportButton.setImage(UIImage(named: "Icons_24px_Close"), for: .normal)

        reportButton.backgroundColor = .black.withAlphaComponent(0.4)
        reportButton.tintColor = .white
        reportButton.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        reportButton.addTarget(self, action: #selector(floatButtonAction(sender:)), for: .touchUpInside)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragAction(gesture:)))
        reportButton.addGestureRecognizer(panGesture)
    }

    @objc private func dragAction(gesture: UIPanGestureRecognizer) {
        let moveState = gesture.state
        switch moveState {
        case .changed:
            let point = gesture.translation(in: view)
            reportButton.center = CGPoint(x: reportButton.center.x + point.x, y: reportButton.center.y + point.y)
        case .ended:
            let point = gesture.translation(in: view)
            var newPoint = CGPoint(x: reportButton.center.x + point.x, y: reportButton.center.y + point.y)
            if newPoint.x < view.bounds.width / 2.0 {
                newPoint.x = 40.0
            } else {
                newPoint.x = view.bounds.width - 40.0
            }
            if newPoint.y <= 40.0 {
                newPoint.y = 40.0
            } else if newPoint.y >= view.bounds.height - 40.0 {
                newPoint.y = view.bounds.height - 40.0
            }
            UIView.animate(withDuration: 0.5) {
                self.reportButton.center = newPoint
            }
        default:
            break
        }
        gesture.setTranslation(.zero, in: view)
    }

    @objc private func floatButtonAction(sender _: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
