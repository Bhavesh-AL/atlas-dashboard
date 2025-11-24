import 'dart:async';
import 'package:atlas_dashboard/models/user_models.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // <--- ADDED IMPORT
import 'package:firebase_database/firebase_database.dart';

// --- EVENTS ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class _AuthStateChanged extends AuthEvent {
  final User? firebaseUser;
  const _AuthStateChanged(this.firebaseUser);
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class CreateUser extends AuthEvent {
  final String email;
  final String password;
  final Role role;
  final String? clientId;

  const CreateUser({
    required this.email,
    required this.password,
    required this.role,
    this.clientId,
  });

  @override
  List<Object?> get props => [email, password, role, clientId];
}

// --- STATES ---
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  final List<UserModel> allUsers;
  const Authenticated(this.user, this.allUsers);
  @override
  List<Object> get props => [user, allUsers];
}

class UserCreationSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLOC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final DatabaseReference _databaseReference;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc(this._firebaseAuth, this._databaseReference) : super(AuthInitial()) {
    _userSubscription = _firebaseAuth.authStateChanges().listen((user) {
      add(_AuthStateChanged(user));
    });

    on<_AuthStateChanged>(_onAuthStateChanged);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CreateUser>(_onCreateUser);
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> _onAuthStateChanged(_AuthStateChanged event, Emitter<AuthState> emit) async {
    final firebaseUser = event.firebaseUser;
    if (firebaseUser != null) {
      try {
        final userSnapshot = await _databaseReference.child('users/${firebaseUser.uid}').get();
        if (!userSnapshot.exists) {
          return emit(Unauthenticated());
        }

        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        final role = Role.values.byName(userData['role'] as String? ?? 'client');
        final userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          role: role,
          clientId: userData['clientId'] as String?,
        );

        List<UserModel> allUsers = [];
        if (role == Role.admin || role == Role.moderator) {
          final allUsersSnapshot = await _databaseReference.child('users').get();
          if (allUsersSnapshot.exists) {
            final allUsersData = allUsersSnapshot.value as Map<dynamic, dynamic>;
            allUsers = allUsersData.entries.map((entry) {
              final userData = entry.value as Map<dynamic, dynamic>;
              return UserModel(
                uid: entry.key,
                email: userData['email'] ?? 'N/A',
                role: Role.values.byName(userData['role'] ?? 'client'),
                clientId: userData['clientId'] as String?,
              );
            }).toList();
          }
        }

        emit(Authenticated(userModel, allUsers));
      } catch (e) {
        emit(AuthError('Failed to process user data: ${e.toString()}'));
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An unknown login error occurred.'));
    } catch (e) {
      emit(AuthError('A system error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<AuthState> emit) async {
    try {
      final tempApp = await Firebase.initializeApp(
        name: 'temp_user_creation_${DateTime.now().microsecondsSinceEpoch}', // Unique name
        options: _firebaseAuth.app.options,
      );
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user == null) {
        throw Exception('User creation failed in Firebase.');
      }

      await _databaseReference.child('users/${userCredential.user!.uid}').set({
        'email': event.email,
        'role': event.role.name,
        'clientId': event.clientId,
      });

      await tempApp.delete();

      emit(UserCreationSuccess());

    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'A Firebase error occurred during user creation.'));
    } catch (e) {
      emit(AuthError('A system error occurred: ${e.toString()}'));
    }
  }
}
