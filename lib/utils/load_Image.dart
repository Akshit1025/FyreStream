// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fyrestream/theme_data/default.dart';
import 'package:http/http.dart' as http;

Image loadImage(
  coverImageUrl, {
  placeholderPath = "assets/sample/album_cover_sam1.jpg",
}) {
  ImageProvider<Object> placeHolder = AssetImage(placeholderPath);
  return Image.network(
    coverImageUrl,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        return child;
      } else {
        return Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxHeight > constraints.maxWidth) {
                return SizedBox(
                  height: constraints.maxWidth,
                  width: constraints.maxWidth,
                  child: const CircularProgressIndicator(
                    color: Default_Theme.accentColor2,
                  ),
                );
              } else {
                return SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxHeight,
                  child: const CircularProgressIndicator(
                    color: Default_Theme.accentColor2,
                  ),
                );
              }
            },
          ),
        );
      }
    },
    errorBuilder: (context, error, stackTrace) {
      return Image(image: placeHolder, fit: BoxFit.cover);
    },
  );
}

CachedNetworkImage loadImageCached(
  coverImageURL, {
  placeholderPath = "assets/sample/album_cover_sam1.jpg",
}) {
  ImageProvider<Object> placeHolder = AssetImage(placeholderPath);
  return CachedNetworkImage(
    imageUrl: coverImageURL,
    memCacheWidth: 500,
    // memCacheHeight: 500,
    placeholder: (context, url) => Padding(
      padding: const EdgeInsets.all(10.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxHeight > constraints.maxWidth) {
            return SizedBox(
              height: constraints.maxWidth,
              width: constraints.maxWidth,
              child: const CircularProgressIndicator(
                color: Default_Theme.accentColor2,
              ),
            );
          } else {
            return SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxHeight,
              child: const CircularProgressIndicator(
                color: Default_Theme.accentColor2,
              ),
            );
          }
        },
      ),
    ),
    errorWidget: (context, url, error) =>
        Image(image: placeHolder, fit: BoxFit.cover),
    // fadeInDuration: const Duration(milliseconds: 100),
    fit: BoxFit.cover,
  );
}

Future<ImageProvider> getImageProvider(
  String imageUrl, {
  String placeholderUrl = "assets/sample/album_cover_sam1.jpg",
}) async {
  if (imageUrl != "") {
    final response = await http.head(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      CachedNetworkImageProvider cachedImageProvider =
          CachedNetworkImageProvider(imageUrl);
      return cachedImageProvider;
    } else {
      return AssetImage(placeholderUrl);
    }
  }
  return AssetImage(placeholderUrl);
}
