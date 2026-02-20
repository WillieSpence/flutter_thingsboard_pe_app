// ignore_for_file: parameter_assignments

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thingsboard_app/config/routes/v2/router_2.dart';
import 'package:thingsboard_app/config/themes/tb_theme.dart';
import 'package:thingsboard_app/config/themes/tb_theme_utils.dart';
import 'package:thingsboard_app/constants/app_constants.dart';
import 'package:thingsboard_app/constants/assets_path.dart';
import 'package:thingsboard_app/core/auth/login/models/login_state.dart';
import 'package:thingsboard_app/core/auth/login/provider/login_provider.dart';

import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/select_region/model/region.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/local_database/i_local_database_service.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';
import 'package:thingsboard_app/utils/utils.dart';
part 'wl_provider.g.dart';
part 'wl_provider.freezed.dart';

const defaultLogoUrl = 'LOGO-PE';

@freezed
abstract class WlState with _$WlState {
  const factory WlState({
    required LoginWhiteLabelingParams loginWhiteLabelingParams,
    required WhiteLabelingParams userParams,
    required ThemeData theme,
    required bool isUserWlMode,
    required Widget logo,
  }) = _WlState;
  const WlState._();

  WhiteLabelingParams get wlParams =>
      isUserWlMode ? userParams : loginWhiteLabelingParams;

  bool? get loginShowNameVersion => loginWhiteLabelingParams.showNameVersion;

  bool? get showNameBottom => loginWhiteLabelingParams.showNameBottom;

  bool? get showNameVersion =>
      isUserWlMode
          ? userParams.showNameVersion
          : loginWhiteLabelingParams.showNameVersion;

  String get platformName =>
      (isUserWlMode
          ? userParams.platformName
          : loginWhiteLabelingParams.platformName) ??
      '';

  String get platformVersion =>
      (isUserWlMode
          ? userParams.platformVersion
          : loginWhiteLabelingParams.platformVersion) ??
      '';

  String get platformNameAndVersion => '$platformName v.$platformVersion';

  bool get isCustomLogo =>
      isUserWlMode
          ? userParams.logoImageUrl != defaultLogoUrl
          : loginWhiteLabelingParams.logoImageUrl != defaultLogoUrl;
}

@riverpod
class Wl extends _$Wl {
  late final ThingsboardClient _tbClient;
  late ProviderSubscription<LoginState> _subscription;
  @override
  WlState build() {
    _tbClient = getIt<ITbClientService>().client;

    _subscription = ref.listen(loginProvider, (prev, next) {
      print('wl update');
      updateWhiteLabeling();
    });
    ref.onDispose(() => _subscription.close());
    return WlState(
      loginWhiteLabelingParams: _defaultLoginWlParams,
      userParams: _defaultWLParams,
      theme: _defaultThemeData,
      isUserWlMode: false,
      logo: _defaultLogo,
    );
  }

  static final _defaultWLParams = _createDefaultWlParams();
  static final _defaultThemeData = tbTheme(
    TbThemeUtils.tbPrimary,
    TbThemeUtils.tbPrimaryColor,
    TbThemeUtils.tbAccentColor,
  );
  static final _defaultLoginWlParams = _createDefaultLoginWlParams();

  static final _defaultLogo = SvgPicture.asset(
    ThingsboardImage.thingsBoardWithTitle,
    height: 36 / 3 * 2,
    colorFilter: ColorFilter.mode(TbThemeUtils.tbPrimary, BlendMode.srcIn),
    semanticsLabel: 'ThingsBoard Logo',
  );

  static final _defaultLoginLogo = SvgPicture.asset(
    ThingsboardImage.thingsBoardWithTitle,
    height: 50 / 3 * 2,
    colorFilter: ColorFilter.mode(TbThemeUtils.tbPrimary, BlendMode.srcIn),
    semanticsLabel: 'ThingsBoard Logo',
  );

  static WhiteLabelingParams _createDefaultWlParams() => WhiteLabelingParams(
    logoImageUrl: defaultLogoUrl,
    logoImageHeight: 36,
    appTitle: 'ThingsBoard PE',
    favicon: Favicon(url: 'thingsboard.ico'),
    paletteSettings: PaletteSettings(
      primaryPalette: Palette(type: 'tb-primary'), // translate-me-ignore
      accentPalette: Palette(type: 'tb-accent'), // translate-me-ignore
    ),
    helpLinkBaseUrl: 'https://thingsboard.io',
    enableHelpLinks: true,
    showNameVersion: false,
    platformName: 'ThingsBoard',
    platformVersion: '3.4.1PE',
  );

  static LoginWhiteLabelingParams _createDefaultLoginWlParams() {
    final loginWlParams = LoginWhiteLabelingParams.fromJson(
      _defaultWLParams.toJson(),
    );
    loginWlParams.logoImageHeight = 50;
    loginWlParams.pageBackgroundColor = '#eee';
    loginWlParams.darkForeground = false;
    return loginWlParams;
  }

  static T _mergeDefaults<T extends WhiteLabelingParams>(
    bool isLogin,
    T? wlParams,
    T? targetDefaultWlParams,
  ) {
    if (targetDefaultWlParams == null) {
      if (isLogin) {
        targetDefaultWlParams = _defaultLoginWlParams as T;
      } else {
        targetDefaultWlParams = _defaultWLParams as T;
      }
    }
    if (wlParams == null) {
      if (isLogin) {
        wlParams = LoginWhiteLabelingParams(baseUrl: '') as T;
      } else {
        wlParams = WhiteLabelingParams() as T;
      }
    }

    if (isLogin) {
      final loginWlParams = wlParams as LoginWhiteLabelingParams;
      final targetDefaultLoginWlParams =
          targetDefaultWlParams as LoginWhiteLabelingParams;
      if (loginWlParams.pageBackgroundColor == null &&
          targetDefaultLoginWlParams.pageBackgroundColor != null) {
        loginWlParams.pageBackgroundColor =
            targetDefaultLoginWlParams.pageBackgroundColor;
      }
    }
    if (_isEmpty(wlParams.logoImageUrl)) {
      wlParams.logoImageUrl = targetDefaultWlParams.logoImageUrl;
    }
    wlParams.logoImageHeight ??= targetDefaultWlParams.logoImageHeight;
    if (_isEmpty(wlParams.appTitle)) {
      wlParams.appTitle = targetDefaultWlParams.appTitle;
    }
    if (wlParams.favicon == null || _isEmpty(wlParams.favicon?.url)) {
      wlParams.favicon = targetDefaultWlParams.favicon;
    }
    if (wlParams.paletteSettings == null) {
      wlParams.paletteSettings = targetDefaultWlParams.paletteSettings;
    } else {
      if (wlParams.paletteSettings?.primaryPalette == null ||
          _isEmpty(wlParams.paletteSettings?.primaryPalette?.type)) {
        wlParams.paletteSettings?.primaryPalette =
            targetDefaultWlParams.paletteSettings?.primaryPalette;
      }
      if (wlParams.paletteSettings?.accentPalette == null ||
          _isEmpty(wlParams.paletteSettings?.accentPalette?.type)) {
        wlParams.paletteSettings?.accentPalette =
            targetDefaultWlParams.paletteSettings?.accentPalette;
      }
    }
    if (_isEmpty(wlParams.helpLinkBaseUrl) &&
        !_isEmpty(targetDefaultWlParams.helpLinkBaseUrl)) {
      wlParams.helpLinkBaseUrl = targetDefaultWlParams.helpLinkBaseUrl;
    }
    if (wlParams.enableHelpLinks == null &&
        targetDefaultWlParams.enableHelpLinks != null) {
      wlParams.enableHelpLinks = targetDefaultWlParams.enableHelpLinks;
    }
    wlParams.showNameVersion ??= targetDefaultWlParams.showNameVersion;
    wlParams.platformName ??= targetDefaultWlParams.platformName;
    wlParams.platformVersion ??= targetDefaultWlParams.platformVersion;
    return wlParams;
  }

  static bool _isEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  static bool _wlIsEqual<T extends WhiteLabelingParams>(T? current, T target) {
    if (current == null) {
      return false;
    } else {
      return current.toJson().toString() == target.toJson().toString();
    }
  }

  Future<void> updateWhiteLabeling() async {
    final region = await getIt<ILocalDatabaseService>().getSelectedRegion();
    if (region == null && !ThingsboardAppConstants.ignoreRegionSelection) {
      return;
    }
    if (ref.read(loginProvider).isFullyAuthenticated()) {
      await _loadUserWhiteLabelingParams();
    } else {
      await loadLoginWhiteLabelingParams();
    }
  }

  Future<void> loadLoginWhiteLabelingParams({BuildContext? context}) async {
    var loginWlParams =
        await _tbClient.getWhiteLabelingService().getLoginWhiteLabelParams();
    if (loginWlParams.platformVersion == null) {
      final platformVersion = _tbClient.getPlatformVersion();
      if (platformVersion != null) {
        loginWlParams.platformVersion = platformVersion.versionString();
      }
    }
    loginWlParams = _mergeDefaults(true, loginWlParams, _defaultLoginWlParams);
    final loginThemeData = TbThemeUtils.createTheme(
      loginWlParams.paletteSettings,
    );
    final loginLogo = await _updateImages(
      context ?? globalNavigatorKey.currentContext!,
      _tbClient,
      loginWlParams,
      loginThemeData,
      true,
    );
    state = state.copyWith(
      loginWhiteLabelingParams: loginWlParams,
      theme: loginThemeData,
      logo: loginLogo,
      isUserWlMode: false,
    );
  }

  Future<void> _loadUserWhiteLabelingParams() async {
    var userWlParams =
        await _tbClient.getWhiteLabelingService().getWhiteLabelParams();
    if (userWlParams.platformVersion == null) {
      final platformVersion = _tbClient.getPlatformVersion();
      if (platformVersion != null) {
        userWlParams.platformVersion = platformVersion.versionString();
      }
    }
    userWlParams = _mergeDefaults(false, userWlParams, _defaultWLParams);
    final themeData = TbThemeUtils.createTheme(userWlParams.paletteSettings);
    final logo = await _updateImages(
      globalNavigatorKey.currentContext!,
      _tbClient,
      userWlParams,
      themeData,
      false,
    );

    state = state.copyWith(
      userParams: userWlParams,
      theme: themeData,
      logo: logo,
      isUserWlMode: true,
    );
    state = state.copyWith(isUserWlMode: true);
  }

  Future<Widget> _updateImages(
    BuildContext context,
    ThingsboardClient tbClient,
    WhiteLabelingParams wlParams,
    ThemeData themeData,
    bool isLogin,
  ) async {
    final double height = wlParams.logoImageHeight!.toDouble() / 3 * 2;
    if (wlParams.logoImageUrl == defaultLogoUrl) {
      Region? region;
      return SvgPicture.asset(
        region == Region.europe
            ? ThingsboardImage.thingsBoardEUWithTitle
            : ThingsboardImage.thingsBoardWithTitle,
        height: height,
        colorFilter: ColorFilter.mode(themeData.primaryColor, BlendMode.srcIn),
        semanticsLabel: 'ThingsBoard Logo',
      );
    } else {
      return Utils.imageFromTbImage(
        context,
        tbClient,
        wlParams.logoImageUrl,
        height: height,
        semanticLabel: 'ThingsBoard Logo',
        loginLogo: isLogin,
      );
    }
  }
}
