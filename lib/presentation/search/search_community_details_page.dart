import 'dart:typed_data';
import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/search/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchCommunityDetailsController extends GetxController {
  SearchCommunityDetailsController({required this.communityId});

  final String communityId;
  final CommonListViewController listViewController = CommonListViewController<Book>(pageSize: 20);

  @override
  Future<void> onInit() async {
    super.onInit();

    listViewController.registerNewPageCallback(loadBooks);
  }

  Future<List<Book>> loadBooks(int pageKey) async {
    final BackendResponse response = await BooksBackend.getBooksInCommunity(
      communityId: communityId,
      pageKey: pageKey,
      query: '',
      pageSize: 20,
    );

    if (response.success) {
      List<Book> books = response.payload;

      return books;
    }

    return [];
  }
}

class SearchCommunityDetailsPage extends StatelessWidget {
  const SearchCommunityDetailsPage({
    super.key,
    required this.communityId,
  });

  final String communityId;

  Future<Community?> _findCommunity() async {
    SearchPageController? searchPageController;
    Community? community;

    if (Get.isRegistered<SearchPageController>()) {
      searchPageController = Get.find<SearchPageController>();
    }

    community = searchPageController?.communityListController.itemList.firstWhereOrNull(
      (el) => el.id == communityId,
    );

    if (community == null) {
      final BackendResponse response = await CommunitiesBackend.getCommunityById(communityId);
      if (response.success) {
        community = response.payload;
      }
    }

    return community;
  }

  Widget _communityLibrary(Community community, SearchCommunityDetailsController controller) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community library',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(height: 10),
            Expanded(
              child: Container(
                height: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.surface,
                ),
                alignment: Alignment.center,
                child: CommonListView<Book>(
                  padding: const EdgeInsets.all(10),
                  separator: const VerticalDivider(width: 10),
                  childBuilder: (Book book) => CommonVerticalBookCard(
                    book: book,
                    axis: Axis.horizontal,
                    clickable: false,
                  ),
                  controller: controller.listViewController,
                  axis: Axis.horizontal,
                ),
              ),
            ),
            const Divider(height: 10),
          ],
        );
      },
    );
  }

  Widget _communityInformation(Community community) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.50),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: AspectRatio(
                aspectRatio: 1,
                child: _buildCommunityAvatar(community),
              ),
            ),
            const Divider(height: 20),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                community.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
              ),
            ),
            const Divider(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Created by: ',
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    community.owner.username,
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ],
            ),
            const Divider(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Text('${community.user_count} member${community.user_count == 1 ? '' : 's'}'),
            ),
            const Divider(height: 20),
            Visibility(
              visible: community.description != null,
              child: Column(
                children: [
                  Text(community.description ?? ''),
                  const Divider(height: 20),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Request invite'),
            ),
          ],
        );
      },
    );
  }

  FutureBuilder<Uint8List?> _buildCommunityAvatar(Community community) {
    return FutureBuilder(
      future: CommunitiesBackend.getCommunityAvatar(community),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
          return const CommonLoadingImage();
        }

        if (snapshot.data == null) {
          return Container(
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
          snapshot.data!,
          fit: BoxFit.cover,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GetBuilder(
          init: SearchCommunityDetailsController(communityId: communityId),
          builder: (controller) {
            return Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                Column(
                  children: [
                    Container(
                      height: 250 / 2,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: FutureBuilder(
                    future: _findCommunity(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return const CommonLoadingBody();
                      }

                      final Community community = snapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _communityInformation(community),
                          const Divider(height: 20),
                          Expanded(child: _communityLibrary(community, controller)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }),
    );
  }
}
