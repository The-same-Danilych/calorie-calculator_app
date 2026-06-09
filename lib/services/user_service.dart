import '../database/db_service.dart';
import '../models/user.dart';

/// Сервис для получения текущего пользователя.
class UserService {
  final DatabaseService _db = DatabaseService.instance;
  
  Future<User?> getCurrentUser() async {
    return await _db.getUser();
  }
}