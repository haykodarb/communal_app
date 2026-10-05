import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonCommunityCard extends StatelessWidget {
  const CommonCommunityCard({
    super.key,
    required this.community,
    required this.callback,
  });

  final Community community;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: callback,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 125),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        community.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(height: 5),
                      Text(
                        "${community.user_count} ${'member'.tr}${community.user_count != 1 ? 's' : ''}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 10,
                        ),
                      ),
                      const Divider(height: 5),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          community.description ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: FutureBuilder(
                    future: CommunitiesBackend.getCommunityAvatar(community),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return const CommonLoadingImage();
                      }

                      if (snapshot.data!.payload == null ||
                          !snapshot.data!.success) {
                        return Container(
                          color: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withValues(alpha: 0.50),
                          padding: const EdgeInsets.all(10),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Icon(
                              Atlas.users,
                              color: Theme.of(context).colorScheme.surface,
                              size: 150,
                            ),
                          ),
                        );
                      }

                      return Image.memory(
                        snapshot.data!.payload!,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
