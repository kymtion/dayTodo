
import SwiftUI
import GoogleMobileAds
import UIKit


struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)

        // 여기에 실제 광고 단위 ID를 사용하세요. 테스트 시에는 Google의 테스트 광고 단위 ID를 사용할 수 있습니다.
        banner.adUnitID = "ca-app-pub-9566336929959750/6192457927"
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
