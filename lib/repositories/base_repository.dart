import 'package:ipf_flutter_starter_pack/bases.dart';
import 'package:sepesha_app/services/database_manager.dart';

/// * ---------- Auto Generated Code ---------- * ///

abstract class BaseRepository<T extends BaseDatabaseModel> extends BaseDataRepository<T> {
	BaseRepository(T model, T Function(Map<String, dynamic> map) generator): super(DatabaseManager.instance, model, generator);
	

}