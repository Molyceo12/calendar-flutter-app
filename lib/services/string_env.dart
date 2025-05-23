import 'dart:collection';

class StringEnv extends MapBase<String, String> {
  final Map<String, String> _env = const {
    'TYPE': 'service_account',
    'PROJECT_ID': 'calendar-91627',
    'PRIVATE_KEY_ID': '940e5b1e6c6940f6e2e99ae3f0cd02c7df9dc40f',
    'PRIVATE_KEY': '''-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDlk09mkHSdF5Tp
0fsfm8YyPA1eg8zPDBUFJfvydoMzecExHvGAQ6XNa+c9CoW0E8lWOg/jafzsU2ka
stZ9YQ59Wi69RnB+U3lCpj3HnIOkYOHnz9G1ZKw18qTjhqWTu+JrniW95LTOxMvh
Mb2m3RzkPJguJwOzr+H/mdYbSTM3dygA9dajRIVWfVUGQJishDjpKFICvXRe8dGx
P/wcypJaLF+H9LHpt5b8AB3ZQ6BvY2/tb/KESwkIl8f1Hktr32ZqkURRTdZ7Ttlq
VXSj3AiZInD4klg0Ny96xLCpO9cyRJJ4crd1TzV83QFf2RHnq9aHUO60Vqecwlg9
MkvR2p0HAgMBAAECggEADEyxTH5BHn4kxnGEt0OkwYyRw3ZjPX/ZC8lmWgNQcdcR
ldH3FVdKevAk15KIlEZvxdS0L4u+TGOxoLJj0cbRPGpdplqvlzezVPH2zbV3ILzn
YtXcVzq5YTs1QKgLl0J8gHsyFsjkiPlmhOj3JLP5oslo9nwKSOZg63fwo83vAQch
cDJLrWlz8L40XS+S1OIa3z212UC+QwPcc1GEMKYBUyyCoTZT1CLnYRoC2DvZdGYB
098/2NC+b0sQjwQLhKkRr0xNRvE7PwXrTZnkV4KQxtIddcA9OEeqUhQLPIr6sFz/
5kkMYpzd11znhpUw9jf0UFw+7qczE09JhAE+Kw6cWQKBgQD5krMv1yZRGaDaZUPE
uNlveXT8ffsptB2DfAfVPLyCcTQmElh1pfAylh6Kcw5RXASOdCocdHfzx4FwYXPI
H/EzGeEN3+0vFECGyLYQI0Gpy27x8B/4j7TJ1ZIqO+qliZQswLcbmhZfvb50Xc7G
g+x4hR44c6tT2WnH6Fca292vLwKBgQDrfMbY1cf/m0gWM/eQonAG4vcx3j/kAMT1
3THeaitNFLD7LYeM24ZLWlhTf/fFZBKpMiGPPKhgNyWwN7f8lHhEbB2fA8r3tO+z
dGRTyevHK7C6vn03DfVFnrTBnJVu5yKUdOoWvBuBC2oFYjq9dtsq/0DGQGqmu/e9
VQ5ck2e5qQKBgHyqpCmUnoZKeAhAJ18AO1Us5ZwuziSh3VBNx5fj9AJwy+zsoxV5
o4eRZ4YfPRq1DW2fZ125bCXxFZ5uf6iLFDBDkCEfJ1qqEiWB4zgidG19uljOaxn9
pwBfV9kS/v5bwBGu3ojCKsT+gkGcjmqpgZkeXd8zIHUNGIMMc15uT8lvAoGANfod
4inuc+p19ZDn2CFDqHBx1N5qqqp6exi+i4qubjal8o0XGvRerfsBb/JPKtGrbVju
VFTFC3jYjLHY3G5zustFZuOJrImuv+WX8ZTBFKAxHDz5mpr6c4DTUeXAYvFb/cdm
uNtZOpURMja33CHYTty/TjIJwDopqR5L8nBfQDECgYBuJScSJaBU/tblaTFwPgNm
Lc0nitZm/iTXamecszPLRfoCIKxqfNkTDakkX3g4CDy8+4BUD7eEvWQXtY5T4m3P
5xAW5kkdv+eLVHRVeo4KT2DpQQRPm1jz21ylDtwGQuQLGAEQzbTYEexIV64jBiWG
J4B9wS85APKv/BzNNx974A==
-----END PRIVATE KEY-----''',
    'CLIENT_EMAIL': 'calendar-91627@appspot.gserviceaccount.com',
    'CLIENT_ID': '110800123390369728735',
    'AUTH_URI': 'https://accounts.google.com/o/oauth2/auth',
    'TOKEN_URI': 'https://oauth2.googleapis.com/token',
    'AUTH_PROVIDER_X509_CERT_URL': 'https://www.googleapis.com/oauth2/v1/certs',
    'CLIENT_X509_CERT_URL': 'https://www.googleapis.com/robot/v1/metadata/x509/calendar-91627%40appspot.gserviceaccount.com',
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
