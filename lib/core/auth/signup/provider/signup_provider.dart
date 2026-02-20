import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thingsboard_app/core/auth/oauth2/app_secret_provider.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/device_info/i_device_info_service.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';

part 'signup_provider.g.dart';

@riverpod
class Signup extends _$Signup {
  final _tbClient = getIt<ITbClientService>().client;
  final _deviceInfoService = getIt<IDeviceInfoService>();

  @override
  SignupState build() {
    return const SignupState(
      isSigningUp: false,
      recaptchaResponse: null,
    );
  }

  void setRecaptchaResponse(String? response) {
    state = state.copyWith(recaptchaResponse: response);
  }

  void clearRecaptchaResponse() {
    state = state.copyWith(recaptchaResponse: null);
  }

  Future<SignUpResult> signup(
    SignUpRequest request,
  ) async {
    state = state.copyWith(isSigningUp: true);
    try {
      final result = await _tbClient.getSignupService().signup(request);
      state = state.copyWith(isSigningUp: false);
      return result;
    } catch (e) {
      state = state.copyWith(isSigningUp: false);
      rethrow;
    }
  }

  Future<SignUpRequest> createSignUpRequest({
    required Map<SignUpFieldsId, String> fields,
    required String recaptchaResponse,
  }) async {
    final appSecret = await AppSecretProvider.local().getAppSecret(
      _deviceInfoService.getPlatformType(),
    );

    return SignUpRequest(
      fields: fields,
      recaptchaResponse: recaptchaResponse,
      pkgName: _deviceInfoService.getApplicationId(),
      appSecret: appSecret,
      platform: _deviceInfoService.getPlatformType(),
    );
  }

  Future<void> resendEmailActivation(String email) async {
    await _tbClient.getSignupService().resendEmailActivation(
          email,
          pkgName: _deviceInfoService.getApplicationId(),
          platform: _deviceInfoService.getPlatformType(),
        );
  }
}

class SignupState {
  const SignupState({
    required this.isSigningUp,
    required this.recaptchaResponse,
  });

  final bool isSigningUp;
  final String? recaptchaResponse;

  SignupState copyWith({
    bool? isSigningUp,
    String? recaptchaResponse,
  }) {
    return SignupState(
      isSigningUp: isSigningUp ?? this.isSigningUp,
      recaptchaResponse: recaptchaResponse ?? this.recaptchaResponse,
    );
  }
}
