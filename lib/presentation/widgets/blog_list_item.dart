import 'package:blog_explorer/logic/blogs_provider.dart';
import 'package:blog_explorer/presentation/screens/blog_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

@HiveType(typeId: 0)
class BlogListItem extends StatefulWidget {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? imageUrl;
  @HiveField(2)
  String? title;
  @HiveField(3)
  bool? isFavourite;

  BlogListItem(
      {super.key, this.id, this.imageUrl, this.title, this.isFavourite});

  BlogListItem.fromJson(Map<String, dynamic> json, {super.key}) {
    id = json['id'];
    imageUrl = json['image_url'];
    title = json['title'];
    isFavourite = false;
  }

  @override
  State<BlogListItem> createState() => _BlogListItemState();
}

class _BlogListItemState extends State<BlogListItem> {
  Future<void> toggleFav() async {
    final favStatus = widget.isFavourite ?? false;
    final newItem = BlogListItem(
      id: widget.id,
      title: widget.title,
      imageUrl: widget.imageUrl,
      isFavourite: !favStatus,
    );
    await Provider.of<Blogs>(context, listen: false)
        .toggleFavoriteStatus(newItem);

    setState(() {
      widget.isFavourite = !favStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BlogDetail(
          blogItem: widget,
        ),
      )),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: ShapeDecoration(
            color: Colors.blueGrey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.imageUrl ?? '',
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text('Loading !')
                        ],
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Text("Image Can't Be Loaded")),
                ),
              ),
            ),
            ListTile(
              title: Text(
                widget.title ?? '',
                style: const TextStyle(color: Colors.white),
              ),
              trailing: IconButton(
                onPressed: toggleFav,
                icon: widget.isFavourite!
                    ? const Icon(
                        Icons.favorite_rounded,
                        color: Colors.red,
                      )
                    : const Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.white,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
