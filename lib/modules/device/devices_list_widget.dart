import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/entity/entities_list_widget.dart';
import 'package:thingsboard_app/modules/device/devices_base.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class DevicesListWidget extends EntitiesListPageLinkWidget<DeviceInfo> with DevicesBase {

  DevicesListWidget(TbContext tbContext, {EntitiesListWidgetController? controller}): super(tbContext, controller: controller);

  @override
  void onViewAll() {
    navigateTo('/devices');
  }

}