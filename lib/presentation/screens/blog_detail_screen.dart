import 'package:blog_explorer/presentation/widgets/blog_list_item.dart';
import 'package:flutter/material.dart';

class BlogDetail extends StatefulWidget {
  final BlogListItem blogItem;

  const BlogDetail({
    super.key,
    required this.blogItem,
  });

  @override
  State<BlogDetail> createState() => _BlogDetailState();
}

class _BlogDetailState extends State<BlogDetail> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: h * 0.5,
            width: w,
            child: Image.network(
              widget.blogItem.imageUrl ?? '',
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
          ListTile(
            title: Text(
              widget.blogItem.title ?? '',
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
