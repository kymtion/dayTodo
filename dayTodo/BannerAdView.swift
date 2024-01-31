
import SwiftUI
import GoogleMobileAds
import UIKit


struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        // 배너 광고 테스트 id "ca-app-pub-3940256099942544/2934735716"
        // 실제 배너 광고 id "ca-app-pub-9566336929959750/6192457927"
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            banner.rootViewController = windowScene.windows.first?.rootViewController
        }

        banner.load(GADRequest())
        return banner
    }
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
