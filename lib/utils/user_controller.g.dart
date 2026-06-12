// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserController)
final userControllerProvider = UserControllerProvider._();

final class UserControllerProvider
    extends $NotifierProvider<UserController, UserModel> {
  UserControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userControllerHash();

  @$internal
  @override
  UserController create() => UserController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserModel>(value),
    );
  }
}

String _$userControllerHash() => r'b6239b3b08cdaf980074b7cef85c1bf3cac8bfc3';

abstract class _$UserController extends $Notifier<UserModel> {
  UserModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserModel, UserModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserModel, UserModel>,
              UserModel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
