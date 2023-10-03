import 'package:blog_explorer/presentation/widgets/blog_list_item.dart';
import 'package:hive/hive.dart';

class BlogAdapter extends TypeAdapter<BlogListItem> {
  @override
  final int typeId = 0;

  @override
  BlogListItem read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final imageUrl = reader.readString();
    final isFavorite = reader.readBool();

    return BlogListItem(
      id: id,
      title: title,
      imageUrl: imageUrl,
      isFavourite: isFavorite,
    );
  }

  @override
  void write(BinaryWriter writer, BlogListItem obj) {
    writer.writeString(obj.id!);
    writer.writeString(obj.title!);
    writer.writeString(obj.imageUrl!);
    writer.writeBool(obj.isFavourite!);
  }
}
