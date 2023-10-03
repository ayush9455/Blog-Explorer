import 'dart:convert';

import 'package:blog_explorer/presentation/widgets/blog_list_item.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class Blogs with ChangeNotifier {
  List<BlogListItem> _blogs = [];

  get blogs {
    return _blogs;
  }

  Future<void> toggleFavoriteStatus(BlogListItem item) async {
    final blogsBox = await Hive.openBox<BlogListItem>('blogs');

    blogsBox.delete(item.id);

    blogsBox.put(item.id, item);
  }

  Future<void> fetchBlogs(BuildContext context) async {
    const String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
    const String adminSecret =
        '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'x-hasura-admin-secret': adminSecret,
      });

      if (response.statusCode == 200) {
        List<BlogListItem> loadedBlogs = [];
        final responseData = json.decode(response.body);
        final blogsBox = await Hive.openBox<BlogListItem>('blogs');
        for (var blogData in responseData['blogs']) {
          BlogListItem blogItem =
              BlogListItem.fromJson(blogData as Map<String, dynamic>);

          // Look up the blog in Hive using its ID
          final storedBlog = blogsBox.get(
            blogItem.id,
          );

          if (storedBlog != null) {
            // Set the isFavorite status based on what's stored in Hive
            blogItem.isFavourite = storedBlog.isFavourite;
          }

          loadedBlogs.add(blogItem);
        }
        _blogs = loadedBlogs;

        notifyListeners();
      } else {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            width: MediaQuery.of(context).size.width * 0.9,
            content: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Some Error Occured !',
                  ),
                ),
                InkWell(
                  onTap: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: const Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.grey,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          width: MediaQuery.of(context).size.width * 0.9,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Device Offline !',
                ),
              ),
              InkWell(
                onTap: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: const Icon(
                  Icons.close,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
