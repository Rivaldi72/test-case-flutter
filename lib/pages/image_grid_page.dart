import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_grid_app/bloc/image/image_bloc.dart';
import 'package:image_grid_app/bloc/image/image_event.dart';
import 'package:image_grid_app/bloc/image/image_state.dart';
import 'package:image_grid_app/pages/image_detail_page.dart';

class ImageGridScreen extends StatelessWidget {
  const ImageGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Grid'),
      ),
      body: BlocProvider(
        create: (_) => ImageBloc()..add(LoadImages()),
        child: const ImageGrid(),
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  const ImageGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageBloc, ImageState>(
      builder: (context, state) {
        if (state is ImageLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ImageLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ImageBloc>().add(LoadImages());
            },
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageDetailScreen(
                          imageUrl: state.images[index],
                        ),
                      ),
                    );
                  },
                  child: Image.network(state.images[index]),
                );
              },
            ),
          );
        } else if (state is ImageError) {
          return Center(child: Text(state.message));
        } else {
          return Container();
        }
      },
    );
  }
}
