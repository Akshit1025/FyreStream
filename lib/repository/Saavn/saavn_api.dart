import 'dart:convert';
import 'package:http/http.dart';
import 'package:fyrestream/repository/Saavn/format.dart';
import 'package:logging/logging.dart';

class SaavnAPI {
  Map<String, String> headers = {};
  String baseUrl = 'www.jiosaavn.com';
  String apiStr = '/api.php?_format=json&_marker=0&api_version=4&ctx=web6dot0';
  Map<String, String> endpoints = {
    'homeData': '__call=webapi.getLaunchData',
    'topSearches': '__call=content.getTopSearches',
    'fromToken': '__call=webapi.get',
    'featuredRadio': '__call=webradio.createFeaturedStation',
    'artistRadio': '__call=webradio.createArtistStation',
    'entityRadio': '__call=webradio.createEntityStation',
    'radioSongs': '__call=webradio.getSong',
    'songDetails': '__call=song.getDetails',
    'playlistDetails': '__call=playlist.getDetails',
    'albumDetails': '__call=content.getAlbumDetails',
    'getResults': '__call=search.getResults',
    'albumResults': '__call=search.getAlbumResults',
    'artistResults': '__call=search.getArtistResults',
    'playlistResults': '__call=search.getPlaylistResults',
    'getReco': '__call=reco.getreco',
    'getAlbumReco': '__call=reco.getAlbumReco',
    'artistOtherTopSongs': '__call=search.artistOtherTopSongs',
  };

  Future<Response> getResponse(String params, {bool usev4 = false}) async {
    Uri url;
    if (!usev4) {
      url = Uri.https(
        baseUrl,
        '$apiStr&$params'.replaceAll('&api_version=4', ''),
      );
    } else {
      url = Uri.https(baseUrl, '$apiStr&$params');
    }
    final String languageHeader = 'L=Hindi';
    headers = {'cookie': languageHeader, 'Accept': '*/*'};

    return get(url, headers: headers).onError((error, stackTrace) {
      return Response(
        {'status': 'failure', 'error': error.toString()}.toString(),
        404,
      );
    });
  }

  Future<Map> querySongsSearch(String queryText, {int maxResults = 5}) async {
    final String apiUrl =
        "https://www.jiosaavn.com/api.php?p=1&q=${queryText.replaceAll(' ', '+')}&_format=json&_marker=0&ctx=wap6dot0&n=$maxResults&__call=search.getResults";

    final response = await get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map results = json.decode(response.body) as Map;
      final List getMain = results["results"];
      return {
        "songs": await formatSongsResponse(
          getMain,
          "song",
        ).then((value) => value),
        "error": "",
      };
    } else {
      print("Request failed with status: ${response.statusCode}");
      return {"no": "error"};
    }
  }

  // Future<Map> fetchHomePageData() async {
  //   Map result = {};
  //   try {
  //     final res = await getResponse(endpoints['homeData']!);
  //     if (res.statusCode == 200) {
  //       final Map data = json.decode(res.body) as Map;
  //       result = await formatHomePageData(data);
  //     }
  //   } catch (e) {
  //     Logger.root.severe('Error in fetchHomePageData: $e');
  //   }
  //   return result;
  // }

  Future<Map> getSongFromToken(
    String token,
    String type, {
    int n = 10,
    int p = 1,
  }) async {
    if (n == -1) {
      final String params =
          "token=$token&type=$type&n=5&p=$p&${endpoints['fromToken']}";
      try {
        final res = await getResponse(params);
        if (res.statusCode == 200) {
          final Map getMain = json.decode(res.body) as Map;
          final String count = getMain['list_count'].toString();
          final String params2 =
              "token=$token&type=$type&n=$count&p=$p&${endpoints['fromToken']}";
          final res2 = await getResponse(params2);
          if (res2.statusCode == 200) {
            final Map getMain2 = json.decode(res2.body) as Map;
            if (type == 'album' || type == 'playlist') return getMain2;
            final List responseList = getMain2['songs'] as List;
            return {'songs': responseList, 'title': getMain2['title']};
          }
        }
      } catch (e) {
        Logger.root.severe('Error in getSongFromToken with -1: $e');
      }
      return {'songs': List.empty()};
    } else {
      final String params =
          "token=$token&type=$type&n=$n&p=$p&${endpoints['fromToken']}";
      try {
        final res = await getResponse(params);
        if (res.statusCode == 200) {
          final Map getMain = json.decode(res.body) as Map;
          if (getMain['status'] == 'failure') {
            Logger.root.severe('Error in getSongFromToken response: $getMain');
            return {'songs': List.empty()};
          }
          if (type == 'album' || type == 'playlist') {
            return getMain;
          }
          if (type == 'show') {
            final List responseList = getMain['episodes'] as List;
            return {'songs': responseList};
          }
          if (type == 'mix') {
            final List responseList = getMain['list'] as List;
            return {'songs': responseList};
          }
          final List responseList = getMain['songs'] as List;
          return {'songs': responseList, 'title': getMain['title']};
        }
      } catch (e) {
        Logger.root.severe('Error in getSongFromToken: $e');
      }
      return {'songs': List.empty()};
    }
  }

  Future<List<Map>> fetchSearchResults(String searchQuery) async {
    final Map<String, List> result = {};
    final Map<int, String> position = {};
    List searchedAlbumList = [];
    List searchedPlaylistList = [];
    List searchedArtistList = [];
    List searchedTopQueryList = [];
    // List searchedShowList = [];
    // List searchedEpisodeList = [];

    final String params =
        '__call=autocomplete.get&cc=in&includeMetaTags=1&query=$searchQuery';

    final res = await getResponse(params, usev4: false);
    if (res.statusCode == 200) {
      final getMain = json.decode(res.body);
      final List albumResponseList = getMain['albums']['data'] as List;
      position[getMain['albums']['position'] as int] = 'Albums';

      final List playlistResponseList = getMain['playlists']['data'] as List;
      position[getMain['playlists']['position'] as int] = 'Playlists';

      final List artistResponseList = getMain['artists']['data'] as List;
      position[getMain['artists']['position'] as int] = 'Artists';

      // final List showResponseList = getMain['shows']['data'] as List;
      // position[getMain['shows']['position'] as int] = 'Podcasts';

      // final List episodeResponseList = getMain['episodes']['data'] as List;
      // position[getMain['episodes']['position'] as int] = 'Episodes';

      final List topQuery = getMain['topquery']['data'] as List;

      searchedAlbumList = await formatAlbumResponse(albumResponseList, 'album');
      if (searchedAlbumList.isNotEmpty) {
        result['Albums'] = searchedAlbumList;
      }

      searchedPlaylistList = await formatAlbumResponse(
        playlistResponseList,
        'playlist',
      );
      if (searchedPlaylistList.isNotEmpty) {
        result['Playlists'] = searchedPlaylistList;
      }

      // searchedShowList =
      //     await FormatResponse().formatAlbumResponse(showResponseList, 'show');
      // if (searchedShowList.isNotEmpty) {
      //   result['Podcasts'] = searchedShowList;
      // }

      // searchedEpisodeList = await FormatResponse()
      //     .formatAlbumResponse(episodeResponseList, 'episode');
      // if (searchedEpisodeList.isNotEmpty) {
      //   result['Episodes'] = searchedEpisodeList;
      // }

      searchedArtistList = await formatAlbumResponse(
        artistResponseList,
        'artist',
      );
      if (searchedArtistList.isNotEmpty) {
        result['Artists'] = searchedArtistList;
      }

      if (topQuery.isNotEmpty &&
          (topQuery[0]['type'] != 'playlist' ||
              topQuery[0]['type'] == 'artist' ||
              topQuery[0]['type'] == 'album')) {
        position[getMain['topquery']['position'] as int] = 'Top Result';
        position[getMain['songs']['position'] as int] = 'Songs';

        switch (topQuery[0]['type'] as String) {
          case 'artist':
            searchedTopQueryList = await formatAlbumResponse(
              topQuery,
              'artist',
            );
            break;
          case 'album':
            searchedTopQueryList = await formatAlbumResponse(topQuery, 'album');
            break;
          case 'playlist':
            searchedTopQueryList = await formatAlbumResponse(
              topQuery,
              'playlist',
            );
            break;
          default:
            break;
        }
        if (searchedTopQueryList.isNotEmpty) {
          result['Top Result'] = searchedTopQueryList;
        }
      } else {
        if (topQuery.isNotEmpty && topQuery[0]['type'] == 'song') {
          position[getMain['topquery']['position'] as int] = 'Songs';
        } else {
          position[getMain['songs']['position'] as int] = 'Songs';
        }
      }
    }
    return [result, position];
  }

  Future<Map> fetchSongSearchResults({
    required String searchQuery,
    int count = 20,
    int page = 1,
  }) async {
    final String params =
        "p=$page&q=$searchQuery&n=$count&${endpoints['getResults']}";

    try {
      final res = await getResponse(params);
      if (res.statusCode == 200) {
        final Map getMain = json.decode(res.body) as Map;
        final List responseList = getMain['results'] as List;
        return {
          'songs': await formatSongsResponse(responseList, 'song'),
          'error': '',
        };
      } else {
        return {'songs': List.empty(), 'error': res.body};
      }
    } catch (e) {
      Logger.root.severe('Error in fetchSongSearchResults: $e');
      return {'songs': List.empty(), 'error': e};
    }
  }

  Future<List> getTopSearches() async {
    final response = await get(
      Uri.parse(
        "https://www.jiosaavn.com/api.php?__call=content.getTopSearches",
      ),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List;
    } else {
      print("Request failed with status: ${response.statusCode}");
      return ["error"];
    }
  }
}
