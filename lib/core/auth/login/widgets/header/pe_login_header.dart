import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thingsboard_app/config/routes/v2/routes_config/routes/select_region_routes.dart';
import 'package:thingsboard_app/config/themes/tb_text_styles.dart';
import 'package:thingsboard_app/constants/app_constants.dart';
import 'package:thingsboard_app/core/select_region/model/region.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/endpoint/i_endpoint_service.dart';
import 'package:thingsboard_app/utils/services/wl_provider.dart';

class LoginHeader extends ConsumerWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wl = ref.watch(wlProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Flexible(child: wl.logo),
          if (!ThingsboardAppConstants.ignoreRegionSelection)
            FutureBuilder(
              future: getIt<IEndpointService>().getSelectedRegion(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final region = snapshot.data!;
                  return Row(
                    spacing: 4,
                    children: [
                      TextButton.icon(
                        label: Text(
                          region.regionToString(context),
                          style: TbTextStyles.bodyLarge.copyWith(
                            color: theme.primaryColor,
                          ),

                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent:
                                false, // Disable height for ascent
                            applyHeightToLastDescent: false,
                          ),
                        ),
                        icon: Transform.flip(
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: theme.primaryColor,
                          ),
                        ),
                        iconAlignment: IconAlignment.end,
                        onPressed: () {
                          context.push(
                            '${SelectRegionRoutes.chooseRegion}?region=${region.name}',
                          );
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
        ],
      ),
    );
  }
}
