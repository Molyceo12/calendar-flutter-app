import 'package:flutter/material.dart';
import 'package:calendar_app/models/post.dart';
import 'package:calendar_app/services/api_service.dart';

class ApiProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ApiProvider() {
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _apiService.getPosts();
    } catch (e) {
      _error = 'Failed to load posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Post?> getPost(int id) async {
    try {
      return await _apiService.getPost(id);
    } catch (e) {
      _error = 'Failed to get post: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> createPost(String title, String body) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Using a fixed userId for simplicity
      final post = await _apiService.createPost(title, body, 1);
      _posts.insert(0, post);
      return true;
    } catch (e) {
      _error = 'Failed to create post: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePost(Post post) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPost = await _apiService.updatePost(post);

      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
      return true;
    } catch (e) {
      _error = 'Failed to update post: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deletePost(id);
      _posts.removeWhere((post) => post.id == id);
      return true;
    } catch (e) {
      _error = 'Failed to delete post: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
