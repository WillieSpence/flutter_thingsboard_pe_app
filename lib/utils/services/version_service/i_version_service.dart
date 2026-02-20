import 'package:thingsboard_app/thingsboard_client.dart';

abstract interface class IVersionService {
  bool appUpdateRequired(VersionInfo info);
}
