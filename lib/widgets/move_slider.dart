import 'package:flutter/material.dart';
import 'package:peliculas/models/models.dart';

class MovieSlider extends StatefulWidget {
  final String? title;
  final List<Movie> movies;
  final Function onNextPage;
  const MovieSlider(
      {Key? key, required this.movies, this.title, required this.onNextPage})
      : super(key: key);

  @override
  State<MovieSlider> createState() => _MovieSliderState();
}

class _MovieSliderState extends State<MovieSlider> {
  final ScrollController scrollController = new ScrollController();
  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels >
          scrollController.position.maxScrollExtent - 400) {
        widget.onNextPage();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return Container(
        width: double.infinity,
        height: 240,
        child: const CircularProgressIndicator(),
      );
    }
    return Container(
      width: double.infinity,
      height: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.title!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          const SizedBox(
            height: 5,
          ),
          Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    final movie = widget.movies[index];
                    return _MoviePoster(
                      movie: movie,
                      heroId: '${movie.title}-${index}-${movie.id}',
                    );
                  })),
        ],
      ),
    );
  }
}

//Contenido de los sliders de películas
class _MoviePoster extends StatelessWidget {
  final Movie movie;
  final String heroId;
  _MoviePoster({required this.movie, required this.heroId});

  @override
  Widget build(BuildContext context) {
    movie.heroId = heroId;

    return Container(
      width: 130,
      height: 200,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, 'details', arguments: movie),
            child: Hero(
              tag: movie.heroId!,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                    placeholder: const AssetImage('assets/no-image.jpg'),
                    image: NetworkImage(movie.fullPostering),
                    width: 130,
                    height: 180,
                    fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            movie.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
