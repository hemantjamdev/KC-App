import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../customer/domain/models/customer_model.dart';

part 'customer_session_state.freezed.dart';

@freezed
sealed class CustomerSessionState with _$CustomerSessionState {
  const factory CustomerSessionState.initializing() =
      CustomerSessionInitializing;

  const factory CustomerSessionState.guest() = CustomerSessionGuest;

  const factory CustomerSessionState.authenticated({
    required User firebaseUser,
    CustomerModel? customer,
    @Default(false) bool isProfileLoading,
    AppFailure? profileFailure,
  }) = CustomerSessionAuthenticated;

  const factory CustomerSessionState.failure(AppFailure failure) =
      CustomerSessionFailure;
}
