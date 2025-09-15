import 'db_util.dart';
import 'record_model.dart';

/// 记录数据仓库，纯数据访问
class RecordRepository {
  /// 获取记录列表
  Future<List<RecordModel>> getRecords({
    int offset = 0,
    int limit = 20,
  }) async {
    final dao = DbUtil.recordDao;
    if (dao == null) {
      throw Exception('RecordDao not initialized');
    }

    return await dao.queryPaged(
      offset: offset,
      limit: limit,
      orderBy: 'updateTimestamp DESC',
    );
  }

  /// 添加记录
  Future<int> addRecord(RecordModel record) async {
    final dao = DbUtil.recordDao;
    if (dao == null) {
      throw Exception('RecordDao not initialized');
    }

    return await dao.insert(record);
  }

  /// 更新记录 - 状态、持续时间
  Future<int> updateRecord(String? channel, String state,
      {int? duration}) async {
    final dao = DbUtil.recordDao;
    if (dao == null) {
      throw Exception('RecordDao not initialized');
    }

    if (channel == null || channel.isEmpty) {
      return -1;
    }
    return await dao.updateFieldsByField("channel", channel, {
      "state": state,
      "updateTimestamp": DateTime.now().millisecondsSinceEpoch,
      if (duration != null && duration > 0) "duration": duration,
    });
  }

  /// 删除记录
  Future<int> deleteRecord(String? channel) async {
    final dao = DbUtil.recordDao;
    if (dao == null) {
      throw Exception('RecordDao not initialized');
    }
    if (channel == null || channel.isEmpty) {
      return -1;
    }
    return await dao.deleteByField('channel', channel);
  }

  /// 删除所有记录
  Future<int> deleteAll() async {
    final dao = DbUtil.recordDao;
    if (dao == null) {
      throw Exception('RecordDao not initialized');
    }
    return await dao.deleteAll();
  }
}
