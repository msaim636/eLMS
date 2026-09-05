import 'package:elms/common/cubits/paginated_api_cubit.dart';
import 'package:elms/core/api/api_client.dart';
import 'package:elms/features/notification/models/notification_model.dart';

class FetchNotificationsCubit extends PaginatedApiCubit<NotificationModel> {
  @override
  String get apiUrl => Apis.notifications;

  @override
  NotificationModel Function(Map<String, dynamic>) get fromJson =>
      NotificationModel.fromJson;
}
