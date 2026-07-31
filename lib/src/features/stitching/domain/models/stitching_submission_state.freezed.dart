// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stitching_submission_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StitchingSubmissionState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() submitting,
    required TResult Function(StitchingOrderModel request) success,
    required TResult Function(AppFailure failure) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? submitting,
    TResult? Function(StitchingOrderModel request)? success,
    TResult? Function(AppFailure failure)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? submitting,
    TResult Function(StitchingOrderModel request)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StitchingSubmissionIdle value) idle,
    required TResult Function(StitchingSubmissionSubmitting value) submitting,
    required TResult Function(StitchingSubmissionSuccess value) success,
    required TResult Function(StitchingSubmissionFailure value) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StitchingSubmissionIdle value)? idle,
    TResult? Function(StitchingSubmissionSubmitting value)? submitting,
    TResult? Function(StitchingSubmissionSuccess value)? success,
    TResult? Function(StitchingSubmissionFailure value)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StitchingSubmissionIdle value)? idle,
    TResult Function(StitchingSubmissionSubmitting value)? submitting,
    TResult Function(StitchingSubmissionSuccess value)? success,
    TResult Function(StitchingSubmissionFailure value)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StitchingSubmissionStateCopyWith<$Res> {
  factory $StitchingSubmissionStateCopyWith(
    StitchingSubmissionState value,
    $Res Function(StitchingSubmissionState) then,
  ) = _$StitchingSubmissionStateCopyWithImpl<$Res, StitchingSubmissionState>;
}

/// @nodoc
class _$StitchingSubmissionStateCopyWithImpl<
  $Res,
  $Val extends StitchingSubmissionState
>
    implements $StitchingSubmissionStateCopyWith<$Res> {
  _$StitchingSubmissionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StitchingSubmissionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$StitchingSubmissionIdleImplCopyWith<$Res> {
  factory _$$StitchingSubmissionIdleImplCopyWith(
    _$StitchingSubmissionIdleImpl value,
    $Res Function(_$StitchingSubmissionIdleImpl) then,
  ) = __$$StitchingSubmissionIdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StitchingSubmissionIdleImplCopyWithImpl<$Res>
    extends
        _$StitchingSubmissionStateCopyWithImpl<
          $Res,
          _$StitchingSubmissionIdleImpl
        >
    implements _$$StitchingSubmissionIdleImplCopyWith<$Res> {
  __$$StitchingSubmissionIdleImplCopyWithImpl(
    _$StitchingSubmissionIdleImpl _value,
    $Res Function(_$StitchingSubmissionIdleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StitchingSubmissionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$StitchingSubmissionIdleImpl implements StitchingSubmissionIdle {
  const _$StitchingSubmissionIdleImpl();

  @override
  String toString() {
    return 'StitchingSubmissionState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StitchingSubmissionIdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() submitting,
    required TResult Function(StitchingOrderModel request) success,
    required TResult Function(AppFailure failure) failure,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? submitting,
    TResult? Function(StitchingOrderModel request)? success,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? submitting,
    TResult Function(StitchingOrderModel request)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StitchingSubmissionIdle value) idle,
    required TResult Function(StitchingSubmissionSubmitting value) submitting,
    required TResult Function(StitchingSubmissionSuccess value) success,
    required TResult Function(StitchingSubmissionFailure value) failure,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StitchingSubmissionIdle value)? idle,
    TResult? Function(StitchingSubmissionSubmitting value)? submitting,
    TResult? Function(StitchingSubmissionSuccess value)? success,
    TResult? Function(StitchingSubmissionFailure value)? failure,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StitchingSubmissionIdle value)? idle,
    TResult Function(StitchingSubmissionSubmitting value)? submitting,
    TResult Function(StitchingSubmissionSuccess value)? success,
    TResult Function(StitchingSubmissionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class StitchingSubmissionIdle implements StitchingSubmissionState {
  const factory StitchingSubmissionIdle() = _$StitchingSubmissionIdleImpl;
}

/// @nodoc
abstract class _$$StitchingSubmissionSubmittingImplCopyWith<$Res> {
  factory _$$StitchingSubmissionSubmittingImplCopyWith(
    _$StitchingSubmissionSubmittingImpl value,
    $Res Function(_$StitchingSubmissionSubmittingImpl) then,
  ) = __$$StitchingSubmissionSubmittingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StitchingSubmissionSubmittingImplCopyWithImpl<$Res>
    extends
        _$StitchingSubmissionStateCopyWithImpl<
          $Res,
          _$StitchingSubmissionSubmittingImpl
        >
    implements _$$StitchingSubmissionSubmittingImplCopyWith<$Res> {
  __$$StitchingSubmissionSubmittingImplCopyWithImpl(
    _$StitchingSubmissionSubmittingImpl _value,
    $Res Function(_$StitchingSubmissionSubmittingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StitchingSubmissionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$StitchingSubmissionSubmittingImpl
    implements StitchingSubmissionSubmitting {
  const _$StitchingSubmissionSubmittingImpl();

  @override
  String toString() {
    return 'StitchingSubmissionState.submitting()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StitchingSubmissionSubmittingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() submitting,
    required TResult Function(StitchingOrderModel request) success,
    required TResult Function(AppFailure failure) failure,
  }) {
    return submitting();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? submitting,
    TResult? Function(StitchingOrderModel request)? success,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return submitting?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? submitting,
    TResult Function(StitchingOrderModel request)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StitchingSubmissionIdle value) idle,
    required TResult Function(StitchingSubmissionSubmitting value) submitting,
    required TResult Function(StitchingSubmissionSuccess value) success,
    required TResult Function(StitchingSubmissionFailure value) failure,
  }) {
    return submitting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StitchingSubmissionIdle value)? idle,
    TResult? Function(StitchingSubmissionSubmitting value)? submitting,
    TResult? Function(StitchingSubmissionSuccess value)? success,
    TResult? Function(StitchingSubmissionFailure value)? failure,
  }) {
    return submitting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StitchingSubmissionIdle value)? idle,
    TResult Function(StitchingSubmissionSubmitting value)? submitting,
    TResult Function(StitchingSubmissionSuccess value)? success,
    TResult Function(StitchingSubmissionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting(this);
    }
    return orElse();
  }
}

abstract class StitchingSubmissionSubmitting
    implements StitchingSubmissionState {
  const factory StitchingSubmissionSubmitting() =
      _$StitchingSubmissionSubmittingImpl;
}

/// @nodoc
abstract class _$$StitchingSubmissionSuccessImplCopyWith<$Res> {
  factory _$$StitchingSubmissionSuccessImplCopyWith(
    _$StitchingSubmissionSuccessImpl value,
    $Res Function(_$StitchingSubmissionSuccessImpl) then,
  ) = __$$StitchingSubmissionSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({StitchingOrderModel request});
}

/// @nodoc
class __$$StitchingSubmissionSuccessImplCopyWithImpl<$Res>
    extends
        _$StitchingSubmissionStateCopyWithImpl<
          $Res,
          _$StitchingSubmissionSuccessImpl
        >
    implements _$$StitchingSubmissionSuccessImplCopyWith<$Res> {
  __$$StitchingSubmissionSuccessImplCopyWithImpl(
    _$StitchingSubmissionSuccessImpl _value,
    $Res Function(_$StitchingSubmissionSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StitchingSubmissionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? request = null}) {
    return _then(
      _$StitchingSubmissionSuccessImpl(
        null == request
            ? _value.request
            : request // ignore: cast_nullable_to_non_nullable
                  as StitchingOrderModel,
      ),
    );
  }
}

/// @nodoc

class _$StitchingSubmissionSuccessImpl implements StitchingSubmissionSuccess {
  const _$StitchingSubmissionSuccessImpl(this.request);

  @override
  final StitchingOrderModel request;

  @override
  String toString() {
    return 'StitchingSubmissionState.success(request: $request)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StitchingSubmissionSuccessImpl &&
            (identical(other.request, request) || other.request == request));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request);

  /// Create a copy of StitchingSubmissionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StitchingSubmissionSuccessImplCopyWith<_$StitchingSubmissionSuccessImpl>
  get copyWith =>
      __$$StitchingSubmissionSuccessImplCopyWithImpl<
        _$StitchingSubmissionSuccessImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() submitting,
    required TResult Function(StitchingOrderModel request) success,
    required TResult Function(AppFailure failure) failure,
  }) {
    return success(request);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? submitting,
    TResult? Function(StitchingOrderModel request)? success,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return success?.call(request);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? submitting,
    TResult Function(StitchingOrderModel request)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(request);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StitchingSubmissionIdle value) idle,
    required TResult Function(StitchingSubmissionSubmitting value) submitting,
    required TResult Function(StitchingSubmissionSuccess value) success,
    required TResult Function(StitchingSubmissionFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StitchingSubmissionIdle value)? idle,
    TResult? Function(StitchingSubmissionSubmitting value)? submitting,
    TResult? Function(StitchingSubmissionSuccess value)? success,
    TResult? Function(StitchingSubmissionFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StitchingSubmissionIdle value)? idle,
    TResult Function(StitchingSubmissionSubmitting value)? submitting,
    TResult Function(StitchingSubmissionSuccess value)? success,
    TResult Function(StitchingSubmissionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class StitchingSubmissionSuccess implements StitchingSubmissionState {
  const factory StitchingSubmissionSuccess(final StitchingOrderModel request) =
      _$StitchingSubmissionSuccessImpl;

  StitchingOrderModel get request;

  /// Create a copy of StitchingSubmissionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StitchingSubmissionSuccessImplCopyWith<_$StitchingSubmissionSuccessImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StitchingSubmissionFailureImplCopyWith<$Res> {
  factory _$$StitchingSubmissionFailureImplCopyWith(
    _$StitchingSubmissionFailureImpl value,
    $Res Function(_$StitchingSubmissionFailureImpl) then,
  ) = __$$StitchingSubmissionFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AppFailure failure});

  $AppFailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$StitchingSubmissionFailureImplCopyWithImpl<$Res>
    extends
        _$StitchingSubmissionStateCopyWithImpl<
          $Res,
          _$StitchingSubmissionFailureImpl
        >
    implements _$$StitchingSubmissionFailureImplCopyWith<$Res> {
  __$$StitchingSubmissionFailureImplCopyWithImpl(
    _$StitchingSubmissionFailureImpl _value,
    $Res Function(_$StitchingSubmissionFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StitchingSubmissionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? failure = null}) {
    return _then(
      _$StitchingSubmissionFailureImpl(
        null == failure
            ? _value.failure
            : failure // ignore: cast_nullable_to_non_nullable
                  as AppFailure,
      ),
    );
  }

  /// Create a copy of StitchingSubmissionState
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

class _$StitchingSubmissionFailureImpl implements StitchingSubmissionFailure {
  const _$StitchingSubmissionFailureImpl(this.failure);

  @override
  final AppFailure failure;

  @override
  String toString() {
    return 'StitchingSubmissionState.failure(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StitchingSubmissionFailureImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of StitchingSubmissionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StitchingSubmissionFailureImplCopyWith<_$StitchingSubmissionFailureImpl>
  get copyWith =>
      __$$StitchingSubmissionFailureImplCopyWithImpl<
        _$StitchingSubmissionFailureImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() submitting,
    required TResult Function(StitchingOrderModel request) success,
    required TResult Function(AppFailure failure) failure,
  }) {
    return failure(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? submitting,
    TResult? Function(StitchingOrderModel request)? success,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return failure?.call(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? submitting,
    TResult Function(StitchingOrderModel request)? success,
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
    required TResult Function(StitchingSubmissionIdle value) idle,
    required TResult Function(StitchingSubmissionSubmitting value) submitting,
    required TResult Function(StitchingSubmissionSuccess value) success,
    required TResult Function(StitchingSubmissionFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StitchingSubmissionIdle value)? idle,
    TResult? Function(StitchingSubmissionSubmitting value)? submitting,
    TResult? Function(StitchingSubmissionSuccess value)? success,
    TResult? Function(StitchingSubmissionFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StitchingSubmissionIdle value)? idle,
    TResult Function(StitchingSubmissionSubmitting value)? submitting,
    TResult Function(StitchingSubmissionSuccess value)? success,
    TResult Function(StitchingSubmissionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class StitchingSubmissionFailure implements StitchingSubmissionState {
  const factory StitchingSubmissionFailure(final AppFailure failure) =
      _$StitchingSubmissionFailureImpl;

  AppFailure get failure;

  /// Create a copy of StitchingSubmissionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StitchingSubmissionFailureImplCopyWith<_$StitchingSubmissionFailureImpl>
  get copyWith => throw _privateConstructorUsedError;
}
