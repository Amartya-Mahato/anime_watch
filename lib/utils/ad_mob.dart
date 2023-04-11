import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMob {
   
  static BannerAd get bannerAd => BannerAd(
        adUnitId: 'ca-app-pub-9311446544168057/4514989102',
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );

  static NativeAd get nativeAd => NativeAd(
        adUnitId: 'ca-app-pub-9311446544168057/6930852159',
        factoryId: 'listTile',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (Ad ad) => log('Ad loaded.'),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            log('Ad failed to load: $error');
          },
        ),
      );
}
