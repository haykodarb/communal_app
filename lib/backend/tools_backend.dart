import 'dart:io';
import 'dart:typed_data';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/tool.dart';
import 'package:communal/models/community.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ToolsBackend {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<Uint8List> getToolImage(Tool tool) async {
    FileInfo? file = await DefaultCacheManager().getFileFromCache(tool.image_path);

    Uint8List bytes;

    if (file != null) {
      bytes = await file.file.openRead().toBytes();
    } else {
      bytes = await _client.storage.from('tool_images').download(tool.image_path);

      await DefaultCacheManager().putFile(tool.image_path, bytes, key: tool.image_path);
    }

    return bytes;
  }

  static Future<BackendResponse> updateTool(Tool tool, File? image) async {
    try {
      final String userId = _client.auth.currentUser!.id;
      final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

      String fileName;

      if (image != null) {
        final String imageExtension = image.path.split('.').last;

        fileName = '/$userId/$currentTime.$imageExtension';

        await _client.storage.from('tool_images').upload(
              fileName,
              image,
              retryAttempts: 5,
            );
      } else {
        fileName = tool.image_path;
      }

      final Map<String, dynamic> response = await _client
          .from('tools')
          .update(
            {
              'name': tool.name,
              'image_path': fileName,
              'available': tool.available,
              'description': tool.description,
            },
          )
          .eq('id', tool.id)
          .select('*, profiles(*)')
          .single();

      return BackendResponse(
        success: response.isNotEmpty,
        payload: response.isNotEmpty ? Tool.fromMap(response) : 'Could not update tool. Please try again.',
      );
    } on StorageException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } catch (error) {
      return BackendResponse(success: false, payload: error);
    }
  }

  static Future<BackendResponse> addTool(Tool tool, File image) async {
    try {
      final String userId = _client.auth.currentUser!.id;
      final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
      final String imageExtension = image.path.split('.').last;

      final String pathToUpload = '/$userId/$currentTime.$imageExtension';

      await _client.storage.from('tool_images').upload(
            pathToUpload,
            image,
            retryAttempts: 5,
          );

      final Map<String, dynamic> response = await _client
          .from('tools')
          .insert(
            {
              'name': tool.name,
              'owner': _client.auth.currentUser!.id,
              'image_path': pathToUpload,
              'description': tool.description,
              'available': tool.available,
            },
          )
          .select('*, profiles(*)')
          .single();

      return BackendResponse(
        success: response.isNotEmpty,
        payload: response.isNotEmpty ? Tool.fromMap(response) : 'Could not create tool. Please try again.',
      );
    } on StorageException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> deleteTool(Tool tool) async {
    try {
      final List<dynamic> response = await _client.from('tools').delete().eq('id', tool.id).select();

      if (response.isNotEmpty) {
        _client.storage.from('tool_images').remove(
          [tool.image_path],
        );
      }

      return BackendResponse(success: response.isNotEmpty, payload: response);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> searchOwnerToolsByQuery(String query) async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final List<Map<String, dynamic>> response = await _client
          .from('tools')
          .select('*, profiles(*)')
          .ilike('name', '%$query%')
          .eq('owner', userId)
          .limit(10)
          .order('created_at');

      final List<Tool> toolList = response
          .map(
            (Map<String, dynamic> element) => Tool.fromMap(element),
          )
          .toList();

      return BackendResponse(
        success: true,
        payload: toolList,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getAllToolsForUser() async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final List<Map<String, dynamic>> response =
          await _client.from('tools').select('*, profiles(*)').eq('owner', userId).limit(10).order('created_at');

      final List<Tool> toolList = response
          .map(
            (Map<String, dynamic> element) => Tool.fromMap(element),
          )
          .toList();

      return BackendResponse(
        success: true,
        payload: toolList,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getToolById(String id) async {
    try {
      final Map<String, dynamic>? response =
          await _client.from('tools').select('*, profiles(*)').eq('id', id).maybeSingle();

      return BackendResponse(
        success: response != null,
        payload: response != null ? Tool.fromMap(response) : null,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getToolsInCommunity(Community community, int index, String query) async {
    try {
      final List<dynamic> toolsResponse = await _client
          .rpc(
            'get_tools_community',
            params: {
              'community_id': community.id,
              'offset_num': index * 10,
              'limit_num': 10,
              'search_query': query,
            },
          )
          .select('*, profiles(*)')
          .limit(10)
          .order('created_at');

      final List<Tool> listOfTools = toolsResponse
          .map(
            (element) => Tool.fromMap(element),
          )
          .toList();

      return BackendResponse(
        success: true,
        payload: listOfTools,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }
}
