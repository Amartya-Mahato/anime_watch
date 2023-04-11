import 'dart:convert';
import 'dart:developer';
import 'package:anime_watch/modules/gogo_anime/gogo_anime_info.dart';
import 'package:anime_watch/modules/gogo_anime/gogo_search.dart';
import 'package:anime_watch/modules/gogo_anime/gogo_stream.dart';
import 'package:anime_watch/modules/gogo_anime/gogo_to_aring.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class GogoApi {
  static Future<GogoAnimeInfo> fetchAnimeInfo(String anime) async {
    // String name = anime.replaceAll(RegExp(r' '), '-');
    Response response =
        await http.get(Uri.parse('https://api.consumet.org/anime/gogoanime/info/$anime'));
    var result = json.decode(response.body) as Map<String, dynamic>;
    GogoAnimeInfo info = GogoAnimeInfo.fromJson(result);
    return info;
  }

  static Future<GogoSearch> searchAnime(String anime) async {
    String name = anime.replaceAll(RegExp(r' '), '-');
    bool hasNext = true;
    int i = 0;
    GogoSearch gogoSearch = GogoSearch(currentPage: '0', hasNextPage: true, results: []);
    while (hasNext) {
      Response response =
          await http.get(Uri.parse('https://api.consumet.org/anime/gogoanime/$name?page=$i'));
      Map<String, dynamic> result = json.decode(response.body) as Map<String, dynamic>;
      List<dynamic> list = result['results'];
      for (var val in list) {
        gogoSearch.results!.add(Results(
            id: val['id'],
            title: val['title'],
            url: val['url'],
            image: val['image'],
            releaseDate: val['releaseDate'],
            subOrDub: val['subOrDub']));
      }
      hasNext = result['hasNextPage'] as bool;
      i++;
    }
    return gogoSearch;
  }

  static Future<GogoStream> fetchStreamLinks(String anime) async {
    Response response =
        await http.get(Uri.parse('https://api.consumet.org/anime/gogoanime/watch/$anime'));
    var result = json.decode(response.body) as Map<String, dynamic>;
    GogoStream stream = GogoStream.fromJson(result);
    return stream;
  }

  static Future<GogoTopAiring> fetchTopAiring() async {
    GogoTopAiring gogoTopAiring = GogoTopAiring(currentPage: 0, hasNextPage: true, results: []);
    Response response =
        await http.get(Uri.parse('https://api.consumet.org/anime/gogoanime/top-airing'));
    Map<String, dynamic> result = json.decode(response.body) as Map<String, dynamic>;
    gogoTopAiring = GogoTopAiring.fromMap(result);
    return gogoTopAiring;
  }
}
