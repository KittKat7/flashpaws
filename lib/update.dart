import 'dart:io';

int _version = 0;
int _appVersion = 0;
int get appVersion { return _appVersion; }
void setAppVersion(int ver) { _appVersion = ver; }

Future<void> update(int oldVersion, int newVersion) async {
  try {
    await _update(oldVersion, newVersion);
  } catch (e, stacktrace) {
    print("ERROR $_version > ${e.toString()}");
    print("TRACE $_version > ${stacktrace.toString()}");
    exit(-1);
  }
}

Future<void> _update(int oldVersion, int newVersion) async {

  // Changing flashcard tags type from List<String> to String.
  _version = 2024011300;
  if (oldVersion < _version) {

    print("DEBUG > Updating from $oldVersion to $_version");

    // Update old version to match this version.
    oldVersion = _version;
  }//e 2024011300
}//e update()