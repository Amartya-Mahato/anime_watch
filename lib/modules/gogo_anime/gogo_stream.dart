import 'dart:convert';

GogoStream gogoStreamFromJson(String str) => GogoStream.fromJson(json.decode(str));

String gogoStreamToJson(GogoStream data) => json.encode(data.toJson());

class GogoStream {
    GogoStream({
        required this.headers,
        required this.sources,
        required this.download,
    });

    Headers headers;
    List<Source> sources;
    String download;

    factory GogoStream.fromJson(Map<String, dynamic> json) => GogoStream(
        headers: Headers.fromJson(json["headers"]),
        sources: List<Source>.from(json["sources"].map((x) => Source.fromJson(x))),
        download: json["download"],
    );

    Map<String, dynamic> toJson() => {
        "headers": headers.toJson(),
        "sources": List<dynamic>.from(sources.map((x) => x.toJson())),
        "download": download,
    };
}

class Headers {
    Headers({
        required this.referer,
    });

    String referer;

    factory Headers.fromJson(Map<String, dynamic> json) => Headers(
        referer: json["Referer"],
    );

    Map<String, dynamic> toJson() => {
        "Referer": referer,
    };
}

class Source {
    Source({
        required this.url,
        required this.isM3U8,
        required this.quality,
    });

    String url;
    bool isM3U8;
    String quality;

    factory Source.fromJson(Map<String, dynamic> json) => Source(
        url: json["url"],
        isM3U8: json["isM3U8"],
        quality: json["quality"],
    );

    Map<String, dynamic> toJson() => {
        "url": url,
        "isM3U8": isM3U8,
        "quality": quality,
    };
}
