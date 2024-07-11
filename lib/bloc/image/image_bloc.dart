import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_grid_app/bloc/image/image_event.dart';
import 'package:image_grid_app/bloc/image/image_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  ImageBloc() : super(ImageInitial()) {
    on<ImageEvent>((event, emit) async {
      if (event is LoadImages) {
        try {
          emit(ImageLoading());

          final res =
              await http.get(Uri.parse('https://api.imgflip.com/get_memes'));
          if (res.statusCode == 200) {
            final data = json.decode(res.body);
            final List<String> images = (data['data']['memes'] as List)
                .map((meme) => meme['url'] as String)
                .toList();
            emit(ImageLoaded(images));
          }
        } catch (e) {
          emit(ImageError(e.toString()));
        }
      }
    });
  }
}
