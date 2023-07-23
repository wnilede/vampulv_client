// ignore: implementation_imports
import 'package:xrandom/src/00_ints.dart';
// ignore: implementation_imports
import 'package:xrandom/src/20_seeding.dart';
// ignore: implementation_imports
import 'package:xrandom/src/21_base32.dart';

/// Copy of Xoshiro128pp from xrandom package with added serialization
class SerializableRandom extends RandomBase32 {
  SerializableRandom([int? a, int? b, int? c, int? d]) {
    if (a != null || b != null || c != null || d != null) {
      if (a != null) {
        RangeError.checkValueInInterval(a, 0, UINT32_MAX);
      }
      if (b != null) {
        RangeError.checkValueInInterval(b, 0, UINT32_MAX);
      }
      if (c != null) {
        RangeError.checkValueInInterval(c, 0, UINT32_MAX);
      }
      if (d != null) {
        RangeError.checkValueInInterval(d, 0, UINT32_MAX);
      }

      if (a == 0 && b == 0 && c == 0 && d == 0) {
        throw ArgumentError('The seed should not consist of only zeros.');
      }

      _s0 = a ?? defaultSeedA;
      _s1 = b ?? defaultSeedB;
      _s2 = c ?? defaultSeedC;
      _s3 = d ?? defaultSeedD;
    } else {
      final now = DateTime.now().millisecondsSinceEpoch;
      _s0 = mess2to64A(now, hashCode) & 0xFFFFFFFF;
      _s1 = mess2to64B(now, hashCode) & 0xFFFFFFFF;
      _s2 = mess2to64C(now, hashCode) & 0xFFFFFFFF;
      _s3 = mess2to64D(now, hashCode) & 0xFFFFFFFF;
    }
  }

  late int _s0, _s1, _s2, _s3;

  @override
  int nextRaw32() {
    // https://prng.di.unimi.it/xoshiro128plusplus.c

    final rotlX1 = (_s0 + _s3) & 0xFFFFFFFF;
    final rotl1 = ((rotlX1 << 7) & 0xFFFFFFFF) |
        ( // same as (x) >>> (32-k)
                (rotlX1) >> (32 - 7)) &
            ~(-1 << (64 - (32 - 7)));

    final result = rotl1 + _s0; // #rotl((_S0+_S3)&0xFFFFFFFF, 7) + _S0;

    final t = (_s1 << 9) & 0xFFFFFFFF;

    _s2 ^= _s0;
    _s3 ^= _s1;
    _s1 ^= _s2;
    _s0 ^= _s3;

    _s2 ^= t;

    // ROTL again

    _s3 = ((_s3 << 11) & 0xFFFFFFFF) |
        ( // same as (x) >>> (32-k)
                (_s3) >> (32 - 11)) &
            ~(-1 << (64 - (32 - 11)));

    return result & 0xFFFFFFFF;
  }

  static const defaultSeedA = 0x543f8723;
  static const defaultSeedB = 0xb887dcb9;
  static const defaultSeedC = 0xe97537a6;
  static const defaultSeedD = 0x39e0f840;

  static SerializableRandom seeded() {
    return SerializableRandom(defaultSeedA, defaultSeedB, defaultSeedC, defaultSeedD);
  }

  Map<String, dynamic> toJson() => {'a': _s0, 'b': _s1, 'c': _s2, 'd': _s3};
  factory SerializableRandom.fromJson(Map<String, dynamic> json) {
    if (json['a'] is! int || json['b'] is! int || json['c'] is! int || json['d'] is! int) {
      throw const FormatException();
    }
    try {
      return SerializableRandom(json['a'], json['b'], json['c'], json['d']);
    } on RangeError {
      throw const FormatException();
    } on ArgumentError {
      throw const FormatException();
    }
  }
}
