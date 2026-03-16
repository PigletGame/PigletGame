//
//  AdCoordinator.swift
//  PigletGame
//
//  Created by Diogo Camargo on 16/03/26.
//


import GoogleMobileAds
import UIKit

class AdCoordinator: NSObject, FullScreenContentDelegate {
    static let shared = AdCoordinator()
    var rewardedAd: RewardedAd?
    
    private let testAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    private let adUnitID = "ca-app-pub-3283949901031820/1706911134"

    func loadAd(completion: (() -> Void)? = nil) {
        let request = Request()
        RewardedAd.load(with: testAdUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Falha ao carregar anúncio: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            print("Anúncio Premiado Carregado!")
            completion?()
        }
    }

    func showAd(onReward: @escaping () -> Void) {
        guard let ad = rewardedAd else {
            print("Anúncio não pronto, carregando...")
            loadAd {
                DispatchQueue.main.async {
                    self.showAd(onReward: onReward)
                }
            }
            return
        }

        guard let root = UIApplication
            .shared
            .connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?
            .rootViewController
        else { return }

        ad.present(from: root) {
            onReward()
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        rewardedAd = nil
        loadAd()
    }
}
