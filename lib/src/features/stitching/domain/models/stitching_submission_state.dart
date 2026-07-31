import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/errors/app_failure.dart';
import 'stitching_order_model.dart';

part 'stitching_submission_state.freezed.dart';

@freezed
sealed class StitchingSubmissionState with _$StitchingSubmissionState {
  const factory StitchingSubmissionState.idle() = StitchingSubmissionIdle;

  const factory StitchingSubmissionState.submitting() =
      StitchingSubmissionSubmitting;

  const factory StitchingSubmissionState.success(StitchingOrderModel request) =
      StitchingSubmissionSuccess;

  const factory StitchingSubmissionState.failure(AppFailure failure) =
      StitchingSubmissionFailure;
}
