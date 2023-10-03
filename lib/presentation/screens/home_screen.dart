import 'package:blog_explorer/logic/blogs_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:svg_flutter/svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../widgets/blog_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BlogListItem> loadedBlogs = [];
  List<BlogListItem> searchedBlogs = [];
  bool isloading = false;
  bool isInit = true;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (isInit) {
      loaderFunction();
    }
  }

  Future<void> loaderFunction() async {
    setState(() {
      isloading = true;
    });
    final blogsBox = await Hive.openBox<BlogListItem>('blogs');
    final isOnline = await isDeviceOnline();

    if (!isOnline && blogsBox.isNotEmpty) {
      // Load data from Hive if offline and data is available
      loadedBlogs = blogsBox.values.toList();
      searchedBlogs = loadedBlogs;
    } else {
      if (!mounted) {
        return;
      }
      final blogProvider = Provider.of<Blogs>(context, listen: false);
      await blogProvider.fetchBlogs(context);
      loadedBlogs = blogProvider.blogs;
      searchedBlogs = loadedBlogs;

      // Store data in Hive when fetched from the internet
      blogsBox.clear(); // Clear previous data
      for (var blogData in loadedBlogs) {
        blogsBox.put(blogData.id, blogData);
      }
    }
    setState(() {
      isloading = false;
      isInit = false;
    });
  }

  Future<bool> isDeviceOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      searchedBlogs = loadedBlogs;
    } else {
      final searchResults = loadedBlogs
          .where(
              (item) => item.title!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        searchedBlogs = searchResults;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black87,
      appBar: AppBar(
        leadingWidth: 75,
        backgroundColor: Colors.black87,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SvgPicture.asset(
            'lib/assets/icons/subspace_hor.svg',
          ),
        ),
        title: const Text(
          'Blog Explorer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => loaderFunction(),
        child: isloading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Loading !',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 0.50, color: Color(0xFFE5E5E5)),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x1918141F),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Color(0x0F18141F),
                              blurRadius: 2,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_rounded),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: TextField(
                                onChanged: (value) =>
                                    filterSearchResults(value),
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8),
                                  border: InputBorder.none,
                                  hintText: 'Search Blogs',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF7F7F7F),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              )),
                            ]),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (searchedBlogs.isEmpty)
                        const Center(
                          child: Text(
                            'No Blogs Found !',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final blogData = searchedBlogs[index];
                          return BlogListItem(
                            id: blogData.id,
                            title: blogData.title,
                            imageUrl: blogData.imageUrl,
                            isFavourite: blogData.isFavourite,
                          );
                        },
                        itemCount: searchedBlogs.length,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ),
    );
  }
}
