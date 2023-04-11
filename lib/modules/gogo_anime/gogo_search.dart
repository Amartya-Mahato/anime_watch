class GogoSearch {
  String? currentPage;
  bool? hasNextPage;
  List<Results>? results;

  GogoSearch({required this.currentPage, required this.hasNextPage, required this.results});

  GogoSearch.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    hasNextPage = json['hasNextPage'];
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentPage'] = currentPage;
    data['hasNextPage'] = hasNextPage;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? id;
  String? title;
  String? url;
  String? image;
  String? releaseDate;
  String? subOrDub;

  Results(
      {required this.id,
      required this.title,
      required this.url,
      required this.image,
      required this.releaseDate,
      required this.subOrDub});

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    image = json['image'];
    releaseDate = json['releaseDate'];
    subOrDub = json['subOrDub'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['url'] = url;
    data['image'] = image;
    data['releaseDate'] = releaseDate;
    data['subOrDub'] = subOrDub;
    return data;
  }
}
