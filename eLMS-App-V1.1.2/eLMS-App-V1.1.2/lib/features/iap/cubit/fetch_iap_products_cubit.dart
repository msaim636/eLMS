import 'package:elms/common/models/blueprints.dart';
import 'package:elms/common/models/data_class.dart';
import 'package:elms/features/iap/models/iap_product_model.dart';
import 'package:elms/features/iap/repository/iap_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATES
// ─────────────────────────────────────────────────────────────────────────────

abstract class FetchIapProductsState {}

class FetchIapProductsInitial extends FetchIapProductsState {}

class FetchIapProductsProgress extends FetchIapProductsState {}

class FetchIapProductsSuccess extends SuccessState<IapProductModel>
    implements FetchIapProductsState {
  FetchIapProductsSuccess({required super.data});
}

base class FetchIapProductsError extends ErrorState<dynamic>
    implements FetchIapProductsState {
  FetchIapProductsError({required super.error});
}

// ─────────────────────────────────────────────────────────────────────────────
// CUBIT
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches the IAP product list from the backend and exposes it to the UI.
///
/// Usage:
/// ```dart
/// BlocProvider(
///   create: (_) => FetchIapProductsCubit(IapRepository())..fetch(),
///   child: const YourIapScreen(),
/// )
/// ```
/// Builder pattern:
///
/// ```dart
/// BlocBuilder<FetchIapProductsCubit, FetchIapProductsState>(
///   builder: (context, state) {
///     if (state is FetchIapProductsProgress) return const CustomShimmer();
///     if (state is FetchIapProductsSuccess)  return buildProductList(state.data);
///     if (state is FetchIapProductsError)    return buildError(state.error);
///     return const SizedBox.shrink();
///   },
/// )
/// ```
class FetchIapProductsCubit extends Cubit<FetchIapProductsState> {
  final IapRepository _repository;

  FetchIapProductsCubit(this._repository) : super(FetchIapProductsInitial());

  Future<void> fetch() async {
    try {
      emit(FetchIapProductsProgress());

      final DataClass<IapProductModel> result = await _repository
          .fetchProducts();

      emit(FetchIapProductsSuccess(data: result.data));
    } catch (e) {
      emit(FetchIapProductsError(error: e));
    }
  }
}
