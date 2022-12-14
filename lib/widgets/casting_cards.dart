import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/providers/movies_provider.dart';
import 'package:provider/provider.dart';

class CastingCards extends StatelessWidget {
  final int movieId;
  const CastingCards({required this.movieId});
  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);

    return FutureBuilder(
      future: moviesProvider.getMovieCast(movieId),
      builder: (BuildContext context, AsyncSnapshot<List<Cast>> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 150,
            child: const CupertinoActivityIndicator(),
          );
        }
        final List<Cast> cast = snapshot.data!;
        return Container(
            margin: const EdgeInsets.only(bottom: 30),
            width: double.infinity,
            height: 220,
            child: ListView.builder(
                itemCount: cast.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return _CastCard(castActor: cast[index]);
                }));
      },
    );
  }
}

class _CastCard extends StatelessWidget {
  late Cast castActor;
  _CastCard({required this.castActor});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 110,
      height: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FadeInImage(
              placeholder: const AssetImage('assets/no-image.jpg'),
              image: NetworkImage(castActor.fullProfilePath),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            castActor.name,
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          )
        ],
      ),
    );
  }
}
