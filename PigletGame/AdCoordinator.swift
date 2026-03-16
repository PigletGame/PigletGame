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

    private var rewardedAd: RewardedAd?
    private var pendingCompletion: (() -> Void)?

    #if DEBUG
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    #else
    private let adUnitID = "ca-app-pub-3283949901031820/1706911134"
    #endif

    func loadAd() {
        guard rewardedAd == nil else { return }

        let request = Request()
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Falha ao carregar anúncio: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            print("Anúncio carregado")
        }
    }

    func showAd(onFinished: @escaping () -> Void) {
        guard let ad = rewardedAd else {
            print("Ad não pronto, carregando...")
            loadAd()
            return
        }

        pendingCompletion = onFinished

        guard let root = UIApplication.shared
            .connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController })
            .first else { return }

        ad.present(from: root) {
            print("Usuário ganhou recompensa")
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        rewardedAd = nil
        loadAd()

        DispatchQueue.main.async {
            self.pendingCompletion?()
            self.pendingCompletion = nil
        }
    }
}
