import 'dart:math';
import 'package:faker/faker.dart';
import 'package:glimfo_todo/feature/auth/domain/entities/user_entity.dart';
import 'package:glimfo_todo/core/domain/value_objects/user_id.dart';
import 'package:glimfo_todo/core/domain/value_objects/email.dart';

/// Property-based test generators for UserEntity and related objects
class UserGenerators {
  static final Random _random = Random();
  static final Faker _faker = Faker();

  /// Generates a random UserEntity with valid properties
  static UserEntity generateValidUser({
    UserId? id,
    Email? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    final createdAtValue = createdAt ?? _generateRandomDateTime(
      start: now.subtract(const Duration(days: 365)),
      end: now,
    );
    
    return UserEntity(
      id: id ?? UserId.generate(),
      email: email ?? _generateValidEmail(),
      displayName: displayName ?? _generateValidDisplayName(),
      createdAt: createdAtValue,
      updatedAt: updatedAt ?? (
        _random.nextBool() 
          ? _generateRandomDateTime(
              start: createdAtValue,
              end: now.add(const Duration(hours: 1)),
            )
          : null
      ),
    );
  }

  /// Generates a UserEntity with invalid properties for negative testing
  static Map<String, dynamic> generateInvalidUserData() {
    final invalidEmails = [
      'invalid-email',
      '@domain.com',
      'user@',
      'user@domain',
      '',
      ' ',
      'user space@domain.com',
    ];
    
    final invalidDisplayNames = [
      '',
      ' ',
      '   ',
    ];

    return {
      'email': invalidEmails[_random.nextInt(invalidEmails.length)],
      'displayName': invalidDisplayNames[_random.nextInt(invalidDisplayNames.length)],
    };
  }

  /// Generates a list of random UserEntity objects
  static List<UserEntity> generateUserList({int? count}) {
    final userCount = count ?? _random.nextInt(20) + 1;
    return List.generate(userCount, (index) => generateValidUser());
  }

  /// Generates a random UserId
  static UserId generateUserId() => UserId.generate();

  /// Generates a valid Email
  static Email _generateValidEmail() {
    final domains = ['gmail.com', 'yahoo.com', 'outlook.com', 'example.com'];
    final username = _faker.internet.userName().toLowerCase();
    final domain = domains[_random.nextInt(domains.length)];
    return Email.fromString('$username@$domain');
  }

  /// Generates a valid display name
  static String _generateValidDisplayName() {
    final names = [
      _faker.person.firstName(),
      _faker.person.name(),
      '${_faker.person.firstName()} ${_faker.person.lastName()}',
      _faker.internet.userName(),
    ];
    return names[_random.nextInt(names.length)];
  }

  /// Generates a random DateTime within a range
  static DateTime _generateRandomDateTime({
    required DateTime start,
    required DateTime end,
  }) {
    final difference = end.difference(start).inMilliseconds;
    // Ensure the difference is within valid range for Random.nextInt
    final safeDifference = difference.clamp(1, 2147483647); // Max int32 value
    final randomMilliseconds = _random.nextInt(safeDifference);
    return start.add(Duration(milliseconds: randomMilliseconds));
  }

  /// Generates a UserEntity with specific email domain
  static UserEntity generateUserWithEmailDomain(String domain) {
    final username = _faker.internet.userName().toLowerCase();
    final email = Email.fromString('$username@$domain');
    return generateValidUser(email: email);
  }

  /// Generates credentials for authentication testing
  static Map<String, String> generateValidCredentials() {
    final email = _generateValidEmail();
    final password = _generateValidPassword();
    
    return {
      'email': email.value,
      'password': password,
    };
  }

  /// Generates invalid credentials for negative testing
  static Map<String, String> generateInvalidCredentials() {
    final invalidData = generateInvalidUserData();
    return {
      'email': invalidData['email'],
      'password': _generateInvalidPassword(),
    };
  }

  /// Generates a valid password
  static String _generateValidPassword() {
    final passwords = [
      'password123',
      'SecurePass!',
      'MyPassword2024',
      'TestPass123!',
      '${_faker.lorem.word()}123!',
    ];
    return passwords[_random.nextInt(passwords.length)];
  }

  /// Generates an invalid password for negative testing
  static String _generateInvalidPassword() {
    final invalidPasswords = [
      '', // Empty
      '123', // Too short
      'pass', // Too short
      '1234567', // Too short (7 chars)
    ];
    return invalidPasswords[_random.nextInt(invalidPasswords.length)];
  }
}
