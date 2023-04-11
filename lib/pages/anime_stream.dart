import 'dart:developer';

import 'package:anime_watch/apis/gogo_api.dart';
import 'package:anime_watch/modules/gogo_anime/gogo_anime_info.dart';
import 'package:anime_watch/modules/gogo_anime/gogo_stream.dart';
import 'package:anime_watch/utils/ad_mob.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';

class AnimeStreamPage extends StatefulWidget {
  final String animeName;
  const AnimeStreamPage({super.key, required this.animeName});

  @override
  State<AnimeStreamPage> createState() => _AnimeStreamPageState();
}

class _AnimeStreamPageState extends State<AnimeStreamPage> {
  GogoStream? _gogoStream;
  bool show = true;
  GogoAnimeInfo? _gogoAnimeInfo;
  int quality = 0;
  int episode = 1;
  Duration _duration = const Duration(milliseconds: 0);
  VideoPlayerController? _videoPlayerControllers;
  ChewieController? _chewieController;
  bool videoLoading = true;
  TextEditingController _episodeController = TextEditingController();
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
        initVideo();
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

  Future<void> initVideo() async {
    _videoPlayerControllers = VideoPlayerController.network(_gogoStream!.sources[quality].url);
    if (_videoPlayerControllers != null) {
      _chewieController = _getChewieController();
      _chewieController!.videoPlayerController.initialize().then((_) {
        _videoPlayerControllers!.addListener(() {
          if (_chewieController!.videoPlayerController.value.isInitialized) {
            _duration = _chewieController!.videoPlayerController.value.position;
            if (_duration.inMilliseconds ==
                _videoPlayerControllers!.value.duration.inMilliseconds) {
              if (episode < _gogoAnimeInfo!.episodes.length) {
                nextEpisode();
              } else {
                _duration = const Duration(milliseconds: 0);
                _videoPlayerControllers!.initialize().then((value) {
                  _chewieController!.play();
                });
              }
            }
          }
        });
        videoLoading = false;
        setState(() {});
      });
    }
  }

  List<OptionItem> _additionalOptions(BuildContext context) {
    return [
      OptionItem(
          onTap: () {
            Navigator.pop(context);
            _changeQuality(context);
          },
          iconData: Icons.signal_cellular_alt_rounded,
          title: 'Quality',
          subtitle: _gogoStream!.sources[quality].quality),
    ];
  }

  void nextEpisode() async {
    videoLoading = true;
    setState(() {});
    bool isFull = _chewieController!.isFullScreen;
      _chewieController!.exitFullScreen();
    if (_chewieController != null &&
        _videoPlayerControllers != null &&
        _videoPlayerControllers!.value.isInitialized) {
      _videoPlayerControllers!.removeListener(() {});
      _videoPlayerControllers!.dispose();
      _chewieController!.dispose();
    }
    _duration = const Duration(milliseconds: 0);
    await gogoStreamEpisode(epIndex: episode);

    _videoPlayerControllers = VideoPlayerController.network(_gogoStream!.sources[quality].url);
    _chewieController = _getChewieController();

    _chewieController!.videoPlayerController.initialize().then((value) async {
      _chewieController!.seekTo(_duration).then((value) {
        _videoPlayerControllers!.addListener(() {
          if (_chewieController!.videoPlayerController.value.isInitialized) {
            _duration = _chewieController!.videoPlayerController.value.position;
            if (_duration.inMilliseconds ==
                _videoPlayerControllers!.value.duration.inMilliseconds) {
              if (episode < _gogoAnimeInfo!.episodes.length) {
                nextEpisode();
              } else {
                _duration = const Duration(milliseconds: 0);
                _videoPlayerControllers!.initialize().then((value) {
                  _chewieController!.play();
                });
              }
            }
          }
        });

        videoLoading = false;
        setState(() {});
        _chewieController!.play().then((value) {
          if (isFull) {
            _chewieController!.enterFullScreen();
            setState(() {});
          }
        });
      });
    });
    episode++;
  }

  PersistentBottomSheetController<dynamic> _changeQuality(BuildContext context) {
    return showBottomSheet(
        enableDrag: true,
        elevation: 5,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              height: 300,
              child: ListView.builder(
                  itemCount: _gogoStream!.sources.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Card(
                      shadowColor: Colors.deepPurple.shade800,
                      child: ListTile(
                        title: Text(_gogoStream!.sources[index].quality),
                        onTap: () {
                          quality = index;
                          Navigator.pop(context);
                          videoLoading = true;
                          setState(() {});
                          _chewieController!.pause();
                          _videoPlayerControllers!.dispose();
                          bool isFull = _chewieController!.isFullScreen;
                            _chewieController!.exitFullScreen();
                          _chewieController!.dispose();
                          _videoPlayerControllers =
                              VideoPlayerController.network(_gogoStream!.sources[index].url);
                          _chewieController = _getChewieController();
                          _chewieController!.videoPlayerController.initialize().then((value) async {
                            _chewieController!.seekTo(_duration).then((value) {
                              _videoPlayerControllers!.addListener(() {
                                if (_chewieController!.videoPlayerController.value.isInitialized) {
                                  _duration =
                                      _chewieController!.videoPlayerController.value.position;

                                  if (_duration.inMilliseconds ==
                                      _videoPlayerControllers!.value.duration.inMilliseconds) {
                                    if (episode < _gogoAnimeInfo!.episodes.length) {
                                      nextEpisode();
                                    } else {
                                      _duration = const Duration(milliseconds: 0);
                                      _videoPlayerControllers!.initialize().then((value) {
                                        _chewieController!.play();
                                      });
                                    }
                                  }
                                }
                              });
                              videoLoading = false;
                              setState(() {});
                              _chewieController!.play().then((value) {
                                if (isFull) {
                                  _chewieController!.enterFullScreen();
                                  setState(() {});
                                }
                              });
                            });
                          });
                        },
                      ),
                    );
                  }),
            ),
          );
        });
  }

  Future<void> changeEpisode(int ep) async {
    videoLoading = true;
    setState(() {});
    if (_chewieController != null &&
        _videoPlayerControllers != null &&
        _videoPlayerControllers!.value.isInitialized) {
      _videoPlayerControllers!.removeListener(() {});
      _videoPlayerControllers!.pause();
      _videoPlayerControllers!.dispose();
      _chewieController!.dispose();
    }
    _duration = const Duration(milliseconds: 0);
    await gogoStreamEpisode(epIndex: ep);

    _videoPlayerControllers = VideoPlayerController.network(_gogoStream!.sources[quality].url);
    _chewieController = _getChewieController();

    _chewieController!.videoPlayerController.initialize().then((value) async {
      _chewieController!.seekTo(_duration).then((value) {
        _videoPlayerControllers!.addListener(() {
          if (_chewieController!.videoPlayerController.value.isInitialized) {
            _duration = _chewieController!.videoPlayerController.value.position;
            if (_duration.inMilliseconds ==
                _videoPlayerControllers!.value.duration.inMilliseconds) {
              if (episode < _gogoAnimeInfo!.episodes.length) {
                nextEpisode();
              } else {
                _duration = const Duration(milliseconds: 0);
                _videoPlayerControllers!.initialize().then((value) {
                  _chewieController!.play();
                });
              }
            }
          }
        });

        videoLoading = false;
        setState(() {});
      });
    });
  }

  ChewieController _getChewieController() {
    return ChewieController(
        allowMuting: true,
        allowedScreenSleep: false,
        showControls: true,
        allowFullScreen: true,
        showOptions: true,
        additionalOptions: _additionalOptions,
        controlsSafeAreaMinimum: const EdgeInsets.all(8.0),
        routePageBuilder: (context, animation, secondaryAnimation, controllerProvider) {
          return Scaffold(
            body: Center(
              child: Stack(
                children: [
                  Chewie(
                    controller: _chewieController!,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => _chewieController!.exitFullScreen(),
                  )
                ],
              ),
            ),
          );
        },
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        materialProgressColors: ChewieProgressColors(
            playedColor: const Color.fromARGB(255, 113, 76, 223),
            handleColor: Colors.deepPurple.shade800,
            bufferedColor: const Color.fromARGB(255, 217, 197, 255),
            backgroundColor: const Color.fromARGB(232, 224, 224, 224)),
        placeholder: Container(
          color: Colors.black,
        ),
        videoPlayerController: _videoPlayerControllers!);
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
                              aspectRatio:
                                  _chewieController!.videoPlayerController.value.aspectRatio,
                              child: Chewie(controller: _chewieController!),
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
                        'Episode $episode / ${_gogoAnimeInfo!.episodes.length}',
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
                                    ep < _gogoAnimeInfo!.totalEpisodes &&
                                    ep != 0) {
                                  episode = ep;
                                  await changeEpisode(ep - 1);
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
                                    ep < _gogoAnimeInfo!.totalEpisodes &&
                                    ep != 0) {
                                  episode = ep;
                                  await changeEpisode(ep - 1);
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
                                      episode = index + 1;
                                      _duration = const Duration(milliseconds: 0);
                                      await changeEpisode(index);
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
    if (_chewieController != null) {
      _chewieController!.dispose();
    }
    if (_videoPlayerControllers != null) {
      _videoPlayerControllers!.dispose();
    }
    lastBanner!.dispose();
    firstBanner!.dispose();
    super.dispose();
  }
}
