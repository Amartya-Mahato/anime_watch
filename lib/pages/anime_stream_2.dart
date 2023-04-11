import 'dart:developer';
import 'package:anime_watch/apis/gogo_api.dart';
import 'package:anime_watch/modules/gogo_anime/gogo_anime_info.dart';
import 'package:anime_watch/modules/gogo_anime/gogo_stream.dart';
import 'package:anime_watch/utils/ad_mob.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AnimeStreamPage2 extends StatefulWidget {
  final String animeName;
  const AnimeStreamPage2({super.key, required this.animeName});

  @override
  State<AnimeStreamPage2> createState() => _AnimeStreamPage2State();
}

class _AnimeStreamPage2State extends State<AnimeStreamPage2> {
  GogoStream? _gogoStream;
  bool show = true;
  bool one = true;
  GogoAnimeInfo? _gogoAnimeInfo;
  int quality = 0;
  int episode = 1;
  List<BetterPlayerDataSource> _betterPlayerDataSourceList = [];
  late BetterPlayerConfiguration _betterPlayerConfiguration;
  BetterPlayerPlaylistController? _betterPlayerPlaylistController;
  bool videoLoading = true;
  final TextEditingController _episodeController = TextEditingController();
  BannerAd? firstBanner;
  BannerAd? lastBanner;
  bool loading = true;

  @override
  void initState() {
    firstBanner = AdMob.bannerAd;
    lastBanner = AdMob.bannerAd;
    firstBanner!.load().then((value) {
      lastBanner!.load().then((value) {
        setState(() {});
      });
    });

    gogoInfoFetch().then((value) {
      setState(() {});
      gogoStreamEpisode(epIndex: 0).then((value) {
        if (_gogoAnimeInfo!.episodes.isEmpty) {
          loading = false;
          return;
        }
        _initVideo();
      });
    });

    super.initState();
  }

  Future<void> gogoStreamEpisode({required int epIndex}) async {
    try {
      _gogoStream = await GogoApi.fetchStreamLinks(_gogoAnimeInfo!.episodes[epIndex].id);
    } catch (e) {
      loading = false;
      setState(() {});
    }
  }

  Future<void> gogoInfoFetch() async {
    try {
      _gogoAnimeInfo = await GogoApi.fetchAnimeInfo(widget.animeName);
    } catch (e) {
      loading = false;
      setState(() {});
    }
  }

  Future<void> _initVideo() async {
    videoLoading = true;
    setState(() {});

    _betterPlayerConfiguration = BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        eventListener: (p0) async {
          if (p0.parameters != null) {
            if (p0.parameters!['progress'] != null && p0.parameters!['duration'] != null) {
              Duration progress = p0.parameters!['progress'] as Duration;
              Duration duration = p0.parameters!['duration'] as Duration;
              if (progress.inSeconds == duration.inSeconds) {
                if (!one) {
                  episode++;
                  setState(() {});
                }
                one = true;
              } else if (progress.inMilliseconds > ((duration.inMilliseconds / 3) * 2)) {
                if (one) {
                  _nextEpisode(ep: episode);
                  one = false;
                }
              }
            }
          }
        },
        fit: BoxFit.contain,
        allowedScreenSleep: false,
        autoDetectFullscreenAspectRatio: true,
        autoDetectFullscreenDeviceOrientation: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
            progressBarHandleColor: Colors.deepPurple.shade800,
            controlBarColor: Colors.black45,
            progressBarBufferedColor: Colors.deepPurple.shade300,
            progressBarPlayedColor: Colors.deepPurple.shade600,
            playIcon: Icons.play_arrow_rounded,
            skipBackIcon: Icons.replay_10_rounded,
            skipForwardIcon: Icons.forward_10_rounded,
            muteIcon: Icons.volume_up_rounded,
            unMuteIcon: Icons.volume_off_rounded,
            fullscreenEnableIcon: Icons.fullscreen_rounded,
            fullscreenDisableIcon: Icons.fullscreen_exit_rounded,
            pauseIcon: Icons.pause_circle_filled_rounded,
            overflowMenuIcon: Icons.more_vert_rounded));
    _addDataSource();

    _betterPlayerPlaylistController = BetterPlayerPlaylistController(_betterPlayerDataSourceList,
        betterPlayerConfiguration: _betterPlayerConfiguration);
    videoLoading = false;
    setState(() {});
  }

  void _nextEpisode({required int ep}) async {
    if (ep < _gogoAnimeInfo!.episodes.length) {
      try {
        log('calling next Episode $ep');
        _gogoStream = await GogoApi.fetchStreamLinks(_gogoAnimeInfo!.episodes[ep].id);
        // episode = ep + 1;
        // setState(() {});
      } catch (e) {
        log(e.toString());
      }
      _addDataSource();
    }
  }

  void _addDataSource() {
    Map<String, String> qualities = {};
    for (var val in _gogoStream!.sources) {
      qualities.addEntries({val.quality: val.url}.entries);
    }
    quality = qualities.length - 2;
    _betterPlayerDataSourceList
        .add(BetterPlayerDataSource.network(_gogoStream!.sources[quality].url,
            qualities: qualities,
            bufferingConfiguration: const BetterPlayerBufferingConfiguration(
              minBufferMs: 30000,
              maxBufferMs: 80000,
              bufferForPlaybackMs: 2500,
              bufferForPlaybackAfterRebufferMs: 5000,
            )));
  }

  Future<void> _changeEpisode({required int ep}) async {
    videoLoading = true;
    setState(() {});
    if (ep < _gogoAnimeInfo!.episodes.length) {
      try {
        log('calling change Episode $ep');
        _gogoStream = await GogoApi.fetchStreamLinks(_gogoAnimeInfo!.episodes[ep].id);
        episode = ep + 1;
        setState(() {});
      } catch (e) {
        log(e.toString());
      }
      _createNewDataSource();
    }
  }

  void _createNewDataSource() {
    Map<String, String> qualities = {};
    for (var val in _gogoStream!.sources) {
      qualities.addEntries({val.quality: val.url}.entries);
    }
    quality = qualities.length - 2;

    // _betterPlayerPlaylistController!.betterPlayerController!.pause();
    // _betterPlayerPlaylistController!.betterPlayerController!.dispose();
    // _betterPlayerPlaylistController!.dispose();
    _betterPlayerDataSourceList = [
      BetterPlayerDataSource.network(_gogoStream!.sources[quality].url,
          qualities: qualities,
          bufferingConfiguration: const BetterPlayerBufferingConfiguration(
            minBufferMs: 30000,
            maxBufferMs: 80000,
            bufferForPlaybackMs: 2500,
            bufferForPlaybackAfterRebufferMs: 5000,
          )),
    ];
    // _betterPlayerPlaylistController = BetterPlayerPlaylistController(_betterPlayerDataSourceList,
    //     betterPlayerConfiguration: _betterPlayerConfiguration);
    _betterPlayerPlaylistController!.setupDataSourceList(_betterPlayerDataSourceList);

    log(_betterPlayerDataSourceList[0].url.toString());
    videoLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.deepPurple.shade800,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.black,
        body: _gogoAnimeInfo == null || _gogoAnimeInfo!.episodes.isEmpty
            ? loading
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : const Center(
                    child: Text(
                      'No Data Available',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    !videoLoading
                        ? Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  spreadRadius: 5,
                                  color: Colors.deepPurple.shade800,
                                  offset: const Offset(0, -3),
                                  blurRadius: 30)
                            ]),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: BetterPlayerPlaylist(
                                betterPlayerConfiguration: _betterPlayerConfiguration,
                                betterPlayerPlaylistConfiguration:
                                    const BetterPlayerPlaylistConfiguration(),
                                betterPlayerDataSourceList: _betterPlayerDataSourceList,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  spreadRadius: 5,
                                  color: Colors.deepPurple.shade800,
                                  offset: const Offset(0, -3),
                                  blurRadius: 30)
                            ]),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                color: Colors.black,
                                child: const Center(child: CircularProgressIndicator.adaptive()),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      title: Text(
                        _gogoAnimeInfo!.title,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      subtitle: Text(
                        'Episode $episode / ${_gogoAnimeInfo!.totalEpisodes}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Column(
                        children: [
                          Text(
                            _gogoAnimeInfo!.subOrDub,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.deepPurple.shade200),
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.all(8.0),
                            height: 35,
                            child: Text(
                              'Status: ${_gogoAnimeInfo!.status}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Divider(
                        color: Colors.white,
                      ),
                    ),
                    firstBanner != null
                        ? Container(
                            alignment: Alignment.bottomCenter,
                            width: MediaQuery.of(context).size.width,
                            height: firstBanner!.size.height.toDouble(),
                            child: AdWidget(ad: firstBanner!),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Text(
                            'Episodes',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: const InputDecoration(
                                  hintText: 'Enter no.',
                                  hintStyle: TextStyle(color: Colors.white70, fontSize: 15),
                                  border: UnderlineInputBorder()),
                              controller: _episodeController,
                              onSubmitted: (value) async {
                                int? ep = int.tryParse(value);
                                if (value.isNotEmpty &&
                                    ep != null &&
                                    ep < _gogoAnimeInfo!.episodes.length &&
                                    ep != 0) {
                                  await _changeEpisode(ep: ep - 1);
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.deepPurple.shade800)),
                              onPressed: () async {
                                int? ep = int.tryParse(_episodeController.text);
                                if (_episodeController.text.isNotEmpty &&
                                    ep != null &&
                                    ep < _gogoAnimeInfo!.episodes.length &&
                                    ep != 0) {
                                  await _changeEpisode(ep: ep - 1);
                                }
                              },
                              child: const Text('Go'))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(color: Colors.deepPurple.shade200)),
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7, crossAxisSpacing: 5, mainAxisSpacing: 5),
                              itemCount: _gogoAnimeInfo!.episodes.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      await _changeEpisode(ep: index);
                                    },
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade800,
                                          border: Border.all(color: Colors.deepPurple.shade200),
                                          borderRadius:
                                              const BorderRadius.all(Radius.circular(10))),
                                      child: Center(
                                          child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(color: Colors.white),
                                      )),
                                    ),
                                  ),
                                );
                              })),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Genres',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: _gogoAnimeInfo!.genres.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.deepPurple.shade200),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  _gogoAnimeInfo!.genres[index],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        _gogoAnimeInfo!.description,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    lastBanner != null
                        ? Container(
                            alignment: Alignment.bottomCenter,
                            width: MediaQuery.of(context).size.width,
                            height: lastBanner!.size.height.toDouble(),
                            child: AdWidget(ad: lastBanner!),
                          )
                        : Container(),
                  ],
                ),
              ));
  }

  @override
  void dispose() {
    if (_betterPlayerPlaylistController != null) {
      if (_betterPlayerPlaylistController!.betterPlayerController != null) {
        _betterPlayerPlaylistController!.betterPlayerController!.dispose();
      }
      _betterPlayerPlaylistController!.dispose();
    }
    lastBanner!.dispose();
    firstBanner!.dispose();
    super.dispose();
  }
}
