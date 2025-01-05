import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/utils/utils.dart';
import 'package:pilipala/models/fans/result.dart';

Widget fanItem({required FansItemModel item}) {
  String heroTag = Utils.makeHeroTag(item.mid);
  return Builder(
    builder: (context) => ListTile(
      onTap: () => Get.toNamed('/member?mid=${item.mid}',
          arguments: {'face': item.face, 'heroTag': heroTag}),
      leading: Hero(
        tag: heroTag,
        child: NetworkImgLayer(
          width: 38,
          height: 38,
          type: 'avatar',
          src: item.face ?? '',
        ),
      ),
      title: Text(
        item.uname ?? '',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        item.sign ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      dense: true,
      trailing: const SizedBox(width: 6),
    ),
  );
}
