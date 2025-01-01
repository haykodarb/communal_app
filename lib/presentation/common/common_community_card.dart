import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:flutter/material.dart';

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
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(height: 5),
                      Text(
                        "${community.user_count} member${community.user_count != 1 ? 's' : ''}",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 12,
                        ),
                      ),
                      const Divider(height: 5),
                      const Expanded(child: SizedBox()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              community.description ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AspectRatio(
                aspectRatio: 1,
                child: FutureBuilder(
                  future: CommunitiesBackend.getCommunityAvatar(community),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const CommonLoadingImage();
                    }

                    if (snapshot.data == null) {
                      return Container(
                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.50),
                        child: Icon(
                          Atlas.users,
                          color: Theme.of(context).colorScheme.surface,
                          size: 150,
                        ),
                      );
                    }

                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
