import 'dart:convert';

GogoTopAiring GogoTopAiringFromMap(String str) => GogoTopAiring.fromMap(json.decode(str));

String GogoTopAiringToMap(GogoTopAiring data) => json.encode(data.toMap());

class GogoTopAiring {
    GogoTopAiring({
        this.currentPage,
        this.hasNextPage,
        this.results,
    });

    int? currentPage;
    bool? hasNextPage;
    List<Result>? results;

    GogoTopAiring copyWith({
        int? currentPage,
        bool? hasNextPage,
        List<Result>? results,
    }) => 
        GogoTopAiring(
            currentPage: currentPage ?? this.currentPage,
            hasNextPage: hasNextPage ?? this.hasNextPage,
            results: results ?? this.results,
        );

    factory GogoTopAiring.fromMap(Map<String, dynamic> json) => GogoTopAiring(
        currentPage: json["currentPage"],
        hasNextPage: json["hasNextPage"],
        results: json["results"] == null ? [] : List<Result>.from(json["results"]!.map((x) => Result.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "currentPage": currentPage,
        "hasNextPage": hasNextPage,
        "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toMap())),
    };
}

class Result {
    Result({
        this.id,
        this.title,
        this.image,
        this.url,
        this.genres,
    });

    String? id;
    String? title;
    String? image;
    String? url;
    List<String>? genres;

    Result copyWith({
        String? id,
        String? title,
        String? image,
        String? url,
        List<String>? genres,
    }) => 
        Result(
            id: id ?? this.id,
            title: title ?? this.title,
            image: image ?? this.image,
            url: url ?? this.url,
            genres: genres ?? this.genres,
        );

    factory Result.fromMap(Map<String, dynamic> json) => Result(
        id: json["id"],
        title: json["title"],
        image: json["image"],
        url: json["url"],
        genres: json["genres"] == null ? [] : List<String>.from(json["genres"]!.map((x) => x)),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "image": image,
        "url": url,
        "genres": genres == null ? [] : List<dynamic>.from(genres!.map((x) => x)),
    };
}
