// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CustomerSessionState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initializing,
    required TResult Function() guest,
    required TResult Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )
    authenticated,
    required TResult Function(AppFailure failure) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initializing,
    TResult? Function()? guest,
    TResult? Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )?
    authenticated,
    TResult? Function(AppFailure failure)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initializing,
    TResult Function()? guest,
    TResult Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )?
    authenticated,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomerSessionInitializing value) initializing,
    required TResult Function(CustomerSessionGuest value) guest,
    required TResult Function(CustomerSessionAuthenticated value) authenticated,
    required TResult Function(CustomerSessionFailure value) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomerSessionInitializing value)? initializing,
    TResult? Function(CustomerSessionGuest value)? guest,
    TResult? Function(CustomerSessionAuthenticated value)? authenticated,
    TResult? Function(CustomerSessionFailure value)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomerSessionInitializing value)? initializing,
    TResult Function(CustomerSessionGuest value)? guest,
    TResult Function(CustomerSessionAuthenticated value)? authenticated,
    TResult Function(CustomerSessionFailure value)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerSessionStateCopyWith<$Res> {
  factory $CustomerSessionStateCopyWith(
    CustomerSessionState value,
    $Res Function(CustomerSessionState) then,
  ) = _$CustomerSessionStateCopyWithImpl<$Res, CustomerSessionState>;
}

/// @nodoc
class _$CustomerSessionStateCopyWithImpl<
  $Res,
  $Val extends CustomerSessionState
>
    implements $CustomerSessionStateCopyWith<$Res> {
  _$CustomerSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CustomerSessionInitializingImplCopyWith<$Res> {
  factory _$$CustomerSessionInitializingImplCopyWith(
    _$CustomerSessionInitializingImpl value,
    $Res Function(_$CustomerSessionInitializingImpl) then,
  ) = __$$CustomerSessionInitializingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CustomerSessionInitializingImplCopyWithImpl<$Res>
    extends
        _$CustomerSessionStateCopyWithImpl<
          $Res,
          _$CustomerSessionInitializingImpl
        >
    implements _$$CustomerSessionInitializingImplCopyWith<$Res> {
  __$$CustomerSessionInitializingImplCopyWithImpl(
    _$CustomerSessionInitializingImpl _value,
    $Res Function(_$CustomerSessionInitializingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CustomerSessionInitializingImpl implements CustomerSessionInitializing {
  const _$CustomerSessionInitializingImpl();

  @override
  String toString() {
    return 'CustomerSessionState.initializing()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerSessionInitializingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initializing,
    required TResult Function() guest,
    required TResult Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )
    authenticated,
    required TResult Function(AppFailure failure) failure,
  }) {
    return initializing();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initializing,
    TResult? Function()? guest,
    TResult? Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )?
    authenticated,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return initializing?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initializing,
    TResult Function()? guest,
    TResult Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )?
    authenticated,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (initializing != null) {
      return initializing();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomerSessionInitializing value) initializing,
    required TResult Function(CustomerSessionGuest value) guest,
    required TResult Function(CustomerSessionAuthenticated value) authenticated,
    required TResult Function(CustomerSessionFailure value) failure,
  }) {
    return initializing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomerSessionInitializing value)? initializing,
    TResult? Function(CustomerSessionGuest value)? guest,
    TResult? Function(CustomerSessionAuthenticated value)? authenticated,
    TResult? Function(CustomerSessionFailure value)? failure,
  }) {
    return initializing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomerSessionInitializing value)? initializing,
    TResult Function(CustomerSessionGuest value)? guest,
    TResult Function(CustomerSessionAuthenticated value)? authenticated,
    TResult Function(CustomerSessionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (initializing != null) {
      return initializing(this);
    }
    return orElse();
  }
}

abstract class CustomerSessionInitializing implements CustomerSessionState {
  const factory CustomerSessionInitializing() =
      _$CustomerSessionInitializingImpl;
}

/// @nodoc
abstract class _$$CustomerSessionGuestImplCopyWith<$Res> {
  factory _$$CustomerSessionGuestImplCopyWith(
    _$CustomerSessionGuestImpl value,
    $Res Function(_$CustomerSessionGuestImpl) then,
  ) = __$$CustomerSessionGuestImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CustomerSessionGuestImplCopyWithImpl<$Res>
    extends _$CustomerSessionStateCopyWithImpl<$Res, _$CustomerSessionGuestImpl>
    implements _$$CustomerSessionGuestImplCopyWith<$Res> {
  __$$CustomerSessionGuestImplCopyWithImpl(
    _$CustomerSessionGuestImpl _value,
    $Res Function(_$CustomerSessionGuestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CustomerSessionGuestImpl implements CustomerSessionGuest {
  const _$CustomerSessionGuestImpl();

  @override
  String toString() {
    return 'CustomerSessionState.guest()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerSessionGuestImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initializing,
    required TResult Function() guest,
    required TResult Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )
    authenticated,
    required TResult Function(AppFailure failure) failure,
  }) {
    return guest();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initializing,
    TResult? Function()? guest,
    TResult? Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )?
    authenticated,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return guest?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initializing,
    TResult Function()? guest,
    TResult Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )?
    authenticated,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (guest != null) {
      return guest();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomerSessionInitializing value) initializing,
    required TResult Function(CustomerSessionGuest value) guest,
    required TResult Function(CustomerSessionAuthenticated value) authenticated,
    required TResult Function(CustomerSessionFailure value) failure,
  }) {
    return guest(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomerSessionInitializing value)? initializing,
    TResult? Function(CustomerSessionGuest value)? guest,
    TResult? Function(CustomerSessionAuthenticated value)? authenticated,
    TResult? Function(CustomerSessionFailure value)? failure,
  }) {
    return guest?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomerSessionInitializing value)? initializing,
    TResult Function(CustomerSessionGuest value)? guest,
    TResult Function(CustomerSessionAuthenticated value)? authenticated,
    TResult Function(CustomerSessionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (guest != null) {
      return guest(this);
    }
    return orElse();
  }
}

abstract class CustomerSessionGuest implements CustomerSessionState {
  const factory CustomerSessionGuest() = _$CustomerSessionGuestImpl;
}

/// @nodoc
abstract class _$$CustomerSessionAuthenticatedImplCopyWith<$Res> {
  factory _$$CustomerSessionAuthenticatedImplCopyWith(
    _$CustomerSessionAuthenticatedImpl value,
    $Res Function(_$CustomerSessionAuthenticatedImpl) then,
  ) = __$$CustomerSessionAuthenticatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    User firebaseUser,
    CustomerModel? customer,
    bool isProfileLoading,
    AppFailure? profileFailure,
  });

  $AppFailureCopyWith<$Res>? get profileFailure;
}

/// @nodoc
class __$$CustomerSessionAuthenticatedImplCopyWithImpl<$Res>
    extends
        _$CustomerSessionStateCopyWithImpl<
          $Res,
          _$CustomerSessionAuthenticatedImpl
        >
    implements _$$CustomerSessionAuthenticatedImplCopyWith<$Res> {
  __$$CustomerSessionAuthenticatedImplCopyWithImpl(
    _$CustomerSessionAuthenticatedImpl _value,
    $Res Function(_$CustomerSessionAuthenticatedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firebaseUser = null,
    Object? customer = freezed,
    Object? isProfileLoading = null,
    Object? profileFailure = freezed,
  }) {
    return _then(
      _$CustomerSessionAuthenticatedImpl(
        firebaseUser: null == firebaseUser
            ? _value.firebaseUser
            : firebaseUser // ignore: cast_nullable_to_non_nullable
                  as User,
        customer: freezed == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as CustomerModel?,
        isProfileLoading: null == isProfileLoading
            ? _value.isProfileLoading
            : isProfileLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        profileFailure: freezed == profileFailure
            ? _value.profileFailure
            : profileFailure // ignore: cast_nullable_to_non_nullable
                  as AppFailure?,
      ),
    );
  }

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppFailureCopyWith<$Res>? get profileFailure {
    if (_value.profileFailure == null) {
      return null;
    }

    return $AppFailureCopyWith<$Res>(_value.profileFailure!, (value) {
      return _then(_value.copyWith(profileFailure: value));
    });
  }
}

/// @nodoc

class _$CustomerSessionAuthenticatedImpl
    implements CustomerSessionAuthenticated {
  const _$CustomerSessionAuthenticatedImpl({
    required this.firebaseUser,
    this.customer,
    this.isProfileLoading = false,
    this.profileFailure,
  });

  @override
  final User firebaseUser;
  @override
  final CustomerModel? customer;
  @override
  @JsonKey()
  final bool isProfileLoading;
  @override
  final AppFailure? profileFailure;

  @override
  String toString() {
    return 'CustomerSessionState.authenticated(firebaseUser: $firebaseUser, customer: $customer, isProfileLoading: $isProfileLoading, profileFailure: $profileFailure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerSessionAuthenticatedImpl &&
            (identical(other.firebaseUser, firebaseUser) ||
                other.firebaseUser == firebaseUser) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.isProfileLoading, isProfileLoading) ||
                other.isProfileLoading == isProfileLoading) &&
            (identical(other.profileFailure, profileFailure) ||
                other.profileFailure == profileFailure));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    firebaseUser,
    customer,
    isProfileLoading,
    profileFailure,
  );

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerSessionAuthenticatedImplCopyWith<
    _$CustomerSessionAuthenticatedImpl
  >
  get copyWith =>
      __$$CustomerSessionAuthenticatedImplCopyWithImpl<
        _$CustomerSessionAuthenticatedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initializing,
    required TResult Function() guest,
    required TResult Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )
    authenticated,
    required TResult Function(AppFailure failure) failure,
  }) {
    return authenticated(
      firebaseUser,
      customer,
      isProfileLoading,
      profileFailure,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initializing,
    TResult? Function()? guest,
    TResult? Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )?
    authenticated,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return authenticated?.call(
      firebaseUser,
      customer,
      isProfileLoading,
      profileFailure,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initializing,
    TResult Function()? guest,
    TResult Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )?
    authenticated,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(
        firebaseUser,
        customer,
        isProfileLoading,
        profileFailure,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomerSessionInitializing value) initializing,
    required TResult Function(CustomerSessionGuest value) guest,
    required TResult Function(CustomerSessionAuthenticated value) authenticated,
    required TResult Function(CustomerSessionFailure value) failure,
  }) {
    return authenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomerSessionInitializing value)? initializing,
    TResult? Function(CustomerSessionGuest value)? guest,
    TResult? Function(CustomerSessionAuthenticated value)? authenticated,
    TResult? Function(CustomerSessionFailure value)? failure,
  }) {
    return authenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomerSessionInitializing value)? initializing,
    TResult Function(CustomerSessionGuest value)? guest,
    TResult Function(CustomerSessionAuthenticated value)? authenticated,
    TResult Function(CustomerSessionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(this);
    }
    return orElse();
  }
}

abstract class CustomerSessionAuthenticated implements CustomerSessionState {
  const factory CustomerSessionAuthenticated({
    required final User firebaseUser,
    final CustomerModel? customer,
    final bool isProfileLoading,
    final AppFailure? profileFailure,
  }) = _$CustomerSessionAuthenticatedImpl;

  User get firebaseUser;
  CustomerModel? get customer;
  bool get isProfileLoading;
  AppFailure? get profileFailure;

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerSessionAuthenticatedImplCopyWith<
    _$CustomerSessionAuthenticatedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomerSessionFailureImplCopyWith<$Res> {
  factory _$$CustomerSessionFailureImplCopyWith(
    _$CustomerSessionFailureImpl value,
    $Res Function(_$CustomerSessionFailureImpl) then,
  ) = __$$CustomerSessionFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AppFailure failure});

  $AppFailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$CustomerSessionFailureImplCopyWithImpl<$Res>
    extends
        _$CustomerSessionStateCopyWithImpl<$Res, _$CustomerSessionFailureImpl>
    implements _$$CustomerSessionFailureImplCopyWith<$Res> {
  __$$CustomerSessionFailureImplCopyWithImpl(
    _$CustomerSessionFailureImpl _value,
    $Res Function(_$CustomerSessionFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? failure = null}) {
    return _then(
      _$CustomerSessionFailureImpl(
        null == failure
            ? _value.failure
            : failure // ignore: cast_nullable_to_non_nullable
                  as AppFailure,
      ),
    );
  }

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppFailureCopyWith<$Res> get failure {
    return $AppFailureCopyWith<$Res>(_value.failure, (value) {
      return _then(_value.copyWith(failure: value));
    });
  }
}

/// @nodoc

class _$CustomerSessionFailureImpl implements CustomerSessionFailure {
  const _$CustomerSessionFailureImpl(this.failure);

  @override
  final AppFailure failure;

  @override
  String toString() {
    return 'CustomerSessionState.failure(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerSessionFailureImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerSessionFailureImplCopyWith<_$CustomerSessionFailureImpl>
  get copyWith =>
      __$$CustomerSessionFailureImplCopyWithImpl<_$CustomerSessionFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initializing,
    required TResult Function() guest,
    required TResult Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )
    authenticated,
    required TResult Function(AppFailure failure) failure,
  }) {
    return failure(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initializing,
    TResult? Function()? guest,
    TResult? Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )?
    authenticated,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return failure?.call(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initializing,
    TResult Function()? guest,
    TResult Function(
      User firebaseUser,
      CustomerModel? customer,
      bool isProfileLoading,
      AppFailure? profileFailure,
    )?
    authenticated,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this.failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomerSessionInitializing value) initializing,
    required TResult Function(CustomerSessionGuest value) guest,
    required TResult Function(CustomerSessionAuthenticated value) authenticated,
    required TResult Function(CustomerSessionFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomerSessionInitializing value)? initializing,
    TResult? Function(CustomerSessionGuest value)? guest,
    TResult? Function(CustomerSessionAuthenticated value)? authenticated,
    TResult? Function(CustomerSessionFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomerSessionInitializing value)? initializing,
    TResult Function(CustomerSessionGuest value)? guest,
    TResult Function(CustomerSessionAuthenticated value)? authenticated,
    TResult Function(CustomerSessionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class CustomerSessionFailure implements CustomerSessionState {
  const factory CustomerSessionFailure(final AppFailure failure) =
      _$CustomerSessionFailureImpl;

  AppFailure get failure;

  /// Create a copy of CustomerSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerSessionFailureImplCopyWith<_$CustomerSessionFailureImpl>
  get copyWith => throw _privateConstructorUsedError;
}
