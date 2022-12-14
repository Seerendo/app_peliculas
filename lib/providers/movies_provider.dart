import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/search_movies_response.dart';
import 'package:peliculas/services/config.dart';
import 'package:peliculas/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  List<Movie> onDisplayMovies = [];
  List<Movie> onPopularMovies = [];
  Map<int, List<Cast>> moviesCast = {};
  int _popularPage = 0;

  final deBouncer = Debouncer(duration: Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionStreamController =
      new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream =>
      _suggestionStreamController.stream;

  MoviesProvider() {
    print('MoviesProvider Inicializado');
    getOnDisplayMovies();
    getPopularMovies();
  }

  //Función principal de llamado de películas (base)
  Future<String> _getJsonData(String args, [int page = 1]) async {
    final url = Uri.https(GlobalVars.baseUrl, '3/movie/$args', {
      'api_key': GlobalVars.apiKey,
      'language': GlobalVars.language,
      'page': '$page'
    });
    final response = await http.get(url);
    return response.body;
  }

  //Obter Películas en Cartelera
  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  //Obtener Películas Populares
  getPopularMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData('popular', _popularPage);
    final nowPopularResponse = PopularResponse.fromJson(jsonData);
    onPopularMovies = [...onPopularMovies, ...nowPopularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int moveId) async {
    //Mantener en memoria el mapa
    if (moviesCast.containsKey(moveId)) return moviesCast[moviesCast]!;

    final jsonData = await _getJsonData('$moveId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);
    moviesCast[moveId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  //Buscar movie por id y Future
  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(GlobalVars.baseUrl, '3/search/movie', {
      'api_key': GlobalVars.apiKey,
      'language': GlobalVars.language,
      'query': query,
    });
    final response = await http.get(url);
    final searchMovieResponse = SearchMovieResponse.fromJson(response.body);
    return searchMovieResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    deBouncer.value = '';
    deBouncer.onValue = (value) async {
      final results = await this.searchMovies(searchTerm);
      this._suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      deBouncer.value = searchTerm;
    });
    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}
