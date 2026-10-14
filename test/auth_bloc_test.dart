import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outmed/core/status/load_status.dart';
import 'package:outmed/core/storage/token_store.dart';
import 'package:outmed/features/auth/domain/user_role.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_event.dart';
import 'package:outmed/features/auth/presentation/bloc/auth_state.dart';

void main() {
  late AuthBloc bloc;

  setUp(() {
    bloc = AuthBloc(tokens: TokenStore(), dio: Dio());
  });

  blocTest<AuthBloc, AuthState>(
    'mock login authenticates a buyer',
    build: () => bloc,
    act: (bloc) => bloc.add(
      const AuthLoginRequested(email: 'demo@outmed.sa', password: '12345678'),
    ),
    verify: (bloc) {
      expect(bloc.state.authenticated, isTrue);
      expect(bloc.state.status, LoadStatus.success);
      expect(bloc.state.role, UserRole.buyer);
      expect(bloc.state.errorMessage, isEmpty);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'empty credentials stay signed out',
    build: () => bloc,
    act: (bloc) => bloc.add(const AuthLoginRequested(email: ' ', password: ' ')),
    verify: (bloc) {
      expect(bloc.state.authenticated, isFalse);
      expect(bloc.state.status, LoadStatus.failure);
      expect(bloc.state.errorMessage, isNotEmpty);
    },
  );
}
