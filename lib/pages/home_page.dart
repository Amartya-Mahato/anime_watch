import 'dart:io';

import 'package:anime_watch/apis/gogo_api.dart';
import 'package:anime_watch/modules/gogo_anime/gogo_search.dart';
import 'package:anime_watch/modules/gogo_anime/gogo_to_aring.dart';
import 'package:anime_watch/pages/anime_stream.dart';
import 'package:anime_watch/utils/ad_mob.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'anime_stream_2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GogoSearch? search;
  GogoSearch? dubSearch;
  GogoSearch? subSearch;

  bool isLoading = true;
  String searchText = '';
  late GogoTopAiring _gogoTopAiring;
  BannerAd? topBanner;
  BannerAd? lastBanner;
  bool load = false;
  bool noResult = false;
  TextEditingController _textEditingController = TextEditingController();
  bool isDub = false;

  @override
  void initState() {
    getAds();
    getTopAiring();
    super.initState();
  }

  void getTopAiring() async {
    isLoading = true;
    setState(() {});
    _gogoTopAiring = await GogoApi.fetchTopAiring();
    isLoading = false;
    noResult = _gogoTopAiring.results!.isEmpty ? true : false;
    setState(() {});
  }

  void getAds() {
    topBanner = AdMob.bannerAd;
    lastBanner = AdMob.bannerAd;

    topBanner!.load().then((value) {
      lastBanner!.load().then((value) {
        setState(() {
          load = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                decoration: const BoxDecoration(
                    color: Colors.white60, borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Center(
                          child: Icon(
                        Icons.search_rounded,
                        size: 30,
                        color: Colors.black,
                      )),
                    ),
                    SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width - 60,
                      child: TextField(
                        controller: _textEditingController,
                        textDirection: TextDirection.ltr,
                        onSubmitted: _search,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),
                        decoration: InputDecoration(
                            suffixIcon: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple.shade800,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0))),
                                child: const Text('Go'),
                                onPressed: () => _search(_textEditingController.text),
                              ),
                            ),
                            focusColor: Colors.deepPurple.shade800,
                            fillColor: Colors.deepPurple.shade800,
                            hoverColor: Colors.deepPurple.shade800,
                            hintText: 'Search',
                            hintStyle: const TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                borderSide: BorderSide(color: Colors.black))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            load
                ? SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: AdWidget(
                      ad: topBanner!,
                    ),
                  )
                : Container(),
            const SizedBox(
              height: 2,
            ),
            Row(
              children: [
                search == null && !noResult && !isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Top Airing',
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      )
                    : Container(),
                const Spacer(),
                Center(
                  child: search != null && !noResult && !isLoading
                      ? const Text(
                          'Dub',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
                        )
                      : Container(),
                ),
                search != null && !noResult && !isLoading
                    ? Switch(
                        value: isDub,
                        onChanged: (value) {
                          setState(() {
                            isDub = value;
                          });
                        },
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white60,
                        activeColor: Colors.green.shade500,
                      )
                    : Container(),
              ],
            ),
            !isLoading
                ? !noResult
                    ? Expanded(
                        child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: (Platform.isAndroid || Platform.isIOS) ? 2 : 5,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5),
                            itemCount: search == null
                                ? _gogoTopAiring.results!.length
                                : isDub
                                    ? dubSearch!.results!.length
                                    : subSearch!.results!.length,

                            // : search!.results!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => AnimeStreamPage2(
                                              animeName: search == null
                                                  ? _gogoTopAiring.results![index].id!
                                                  : isDub
                                                      ? dubSearch!.results![index].id!
                                                      : subSearch!.results![index].id!,
                                              // : search!.results![index].id!,
                                            )));
                                  },
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    child: GridTile(
                                      footer: SizedBox(
                                        height: 70,
                                        child: GridTileBar(
                                          backgroundColor: Colors.black54,
                                          title: Text(
                                            search == null
                                                ? _gogoTopAiring.results![index].title.toString()
                                                : isDub
                                                    ? dubSearch!.results![index].title!
                                                    : subSearch!.results![index].title!,
                                            // : search!.results![index].title.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                            style: const TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          trailing: Text(
                                            search == null
                                                ? ''
                                                : isDub
                                                    ? dubSearch!.results![index].subOrDub.toString()
                                                    : subSearch!.results![index].subOrDub
                                                        .toString(),
                                            // : search!.results![index].subOrDub.toString(),
                                            style:
                                                const TextStyle(fontSize: 15, color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            search == null
                                                ? ''
                                                : isDub
                                                    ? dubSearch!.results![index].releaseDate
                                                        .toString()
                                                    : subSearch!.results![index].releaseDate
                                                        .toString(),
                                            // : search!.results![index].releaseDate.toString(),
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ),
                                      child: Image.network(
                                        search == null
                                            ? _gogoTopAiring.results![index].image.toString()
                                            : isDub
                                                ? dubSearch!.results![index].image.toString()
                                                : subSearch!.results![index].image.toString(),
                                        // : search!.results![index].image.toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }))
                    : const Expanded(
                        child: Center(
                          child: Text(
                            'No Results',
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ),
                      )
                : const Expanded(
                    child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  )),
            const SizedBox(
              height: 2,
            ),
            load
                ? SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: AdWidget(
                      ad: lastBanner!,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _search(value) async {
    if (value.isNotEmpty) {
      searchText = value;
      isLoading = true;
      setState(() {});
      search = await GogoApi.searchAnime(value);
      noResult = search!.results!.isEmpty ? true : false;
      isLoading = false;
      subSearch = GogoSearch(currentPage: '', hasNextPage: true, results: []);
      dubSearch = GogoSearch(currentPage: '', hasNextPage: true, results: []);
      for (var v in search!.results!) {
        if (v.subOrDub == 'dub') {
          dubSearch!.results!.add(v);
        } else {
          subSearch!.results!.add(v);
        }
      }
      setState(() {});
    } else {
      search = null;
      noResult = false;
      setState(() {});
    }
  }
}
