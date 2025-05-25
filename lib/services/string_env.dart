import 'dart:collection';

class StringEnv extends MapBase<String, String> {
  final Map<String, String> _env = const {
    'TYPE': 'service_account',
    'PROJECT_ID': 'calendar-91627',
    'PRIVATE_KEY_ID': '37ea0b6b9a28ce562d595d03a96b2c3c627ee3da',
    'PRIVATE_KEY': '''-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCy61/pAceffcSV
gcTIZeEjoPm2OnFug23rB4w7EWlmZrdxnD+nv7mMC6b67CV5+//z1E248xIQpQ/M
IExjnu88UO99GBPOAEc7qnKElxS6r6uke3tDlcfLhvOVMovmyR7qNE3rYKdZU6/D
e+3NkwINbIYcnc5rr/gGWd1nqMLhZlOXu4csW6kXoLq6ArOwa91hCqyvq9qj/32P
XjZuJ0I2ouk8OU5KvVwML20s2ELOxE14mGxzMR5zJiEh/RytpZo8kRrzyMbrsf2i
4AnusK3pSBxKVTwurjCKwxRE/uXPxmh11uHTHOJyv5+tGtUMBAdnGKCV294mj7be
pJDDXlSXAgMBAAECggEAKpv6bdvCJh4GDJLogc8ddGY4QekeLXL4YOIdx81oO/5X
TqOm1zTGI+98d0J41FmqxW84iUS99x/QKM1CU/E8STF/L1vmD4eqby+y8Ren1KPU
bSoJG3nWqIY9iTkN70rTZXRKYDVW9WOENrpTUkNh2D+RmswMJkI0f5K0MyUSMCpP
1S5WF2CYf8TZwCOPK0CzMxCx8gfKDLHUkUF3OVmFjouQkJpdQd7UChhQiaCzs3Oi
8NK6te/rl2AOL6jMe2CyidKBH0tq2y1PMyAuP9L77Ah9AKdmOsxeB5eW0OGgeM/l
kARQdP/dPiF4Unodz7I0gfu2D7z2pigMn7AL0ebdoQKBgQDe/J6kG35nFiGGCDNF
A4lZRQO8wZJxmDAJUJeER218ILX3im8eeRLmgoziq3ehpcArf4PNz+CpMQG9MpIo
TSsDO0W4Frc09jOiNQkbWygOCZKjORmi5NOOUC5yuOcdar6k/SDWhrzqtws78QIj
Tnlz36Sy4+yo80LIyLWj6PWYtwKBgQDNaJDv/uJcandhr7r1BaPkgHoZHNvLJAnk
NNX1aYdMCNWgWBxqBvSsUqPiRGfqPQvNdd3zNLHOPpz84CfXi/uz1xDdCjcrjJkD
VT8F/7H+1clzTsjIuqbL/Wwilc3Vycadit7covt5gCszcFfWtMpWT/feUZQJfosK
jFCLNfCDIQKBgHYkvFzQoFk39Y0RHTDsncHpegBxQwjijFjzFUQloBGLNz4vX45y
sZvmAYU7OggwTK//QLMz96FM8NHwUFYABNESf274whrScyr3FJsk4gUF92Z5o2aV
/KzDOMjZxMHmQ5og71waSU/GqbIZkHtqYZkOHjIV5tbhBDpjdTGiBTXjAoGBAKlI
gyJ3QiB90dNdG0wxkMeRpo6pvO5mzgwYCzkM9mcQZNaXpxsujliyZsPkMmvWUbLL
b9au19asvX6eUdePUyn8lbZFZABtB/G6QI12FEB7+mEgTdM4GJzHR2YdZZzKhPhz
aYYWf/+7RF9JN+sH5jVKBHJhcwp8EqTnzL1d/9BhAoGAJGlSmgwQhUmoboskCjyU
rnnXB8ZjTZd3llWR46A/+GBcXplYeaJP7LNjdxOWI0ZkP9+7gRTcuLPEoWF1orxO
X/VGn44uV5lWCJhaseOOQAeK+bGUsKYRprIMQ3FTB+2WtfJG+LuhUTgpBQx7V6fQ
sIoZ0N5eEj+uohbZyZKzNtE=
-----END PRIVATE KEY-----''',
    'CLIENT_EMAIL':
        'firebase-adminsdk-fbsvc@calendar-91627.iam.gserviceaccount.com',
    'CLIENT_ID': '104332548520861065057',
    'AUTH_URI': 'https://accounts.google.com/o/oauth2/auth',
    'TOKEN_URI': 'https://oauth2.googleapis.com/token',
    'AUTH_PROVIDER_X509_CERT_URL': 'https://www.googleapis.com/oauth2/v1/certs',
    'CLIENT_X509_CERT_URL':
        'https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40calendar-91627.iam.gserviceaccount.com',
    'UNIVERSE_DOMAIN': 'googleapis.com',
  };

  @override
  String? operator [](Object? key) => _env[key];

  @override
  void operator []=(String key, String value) {
    throw UnsupportedError('Cannot modify environment variables');
  }

  @override
  void clear() {
    throw UnsupportedError('Cannot modify environment variables');
  }

  @override
  Iterable<String> get keys => _env.keys;

  @override
  void addAll(Map<String, String> other) {
    throw UnsupportedError('Cannot modify environment variables');
  }

  @override
  bool containsKey(Object? key) => _env.containsKey(key);

  @override
  bool containsValue(Object? value) => _env.containsValue(value);

  @override
  void forEach(void Function(String key, String value) action) {
    _env.forEach(action);
  }

  @override
  bool get isEmpty => _env.isEmpty;

  @override
  bool get isNotEmpty => _env.isNotEmpty;

  @override
  Iterable<String> get values => _env.values;

  @override
  int get length => _env.length;

  @override
  String putIfAbsent(String key, String Function() ifAbsent) {
    throw UnsupportedError('Cannot modify environment variables');
  }

  @override
  String? remove(Object? key) {
    throw UnsupportedError('Cannot modify environment variables');
  }
}
