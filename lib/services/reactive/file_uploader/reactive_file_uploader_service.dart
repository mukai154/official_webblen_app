import 'dart:io';
import 'dart:typed_data';

import 'package:stacked/stacked.dart';

class ReactiveFileUploaderService with ReactiveServiceMixin {
  final _uploadProgress = ReactiveValue<double>(0);
  final _fileToUpload = ReactiveValue<File>(File(""));
  final _fileToUploadByteMemory = ReactiveValue<Uint8List>(Uint8List(0));
  final _uploadingFile = ReactiveValue<bool>(false);

  double get uploadProgress => _uploadProgress.value;
  File get fileToUpload => _fileToUpload.value;
  Uint8List get fileToUploadByteMemory => _fileToUploadByteMemory.value;
  bool get uploadingFile => _uploadingFile.value;

  void updateUploadProgress(double val) => _uploadProgress.value = val;
  void updateFileToUpload(File val) => _fileToUpload.value = val;
  void updateFileToUploadByteMemory(Uint8List val) => _fileToUploadByteMemory.value = val;
  void updateUploadingFile(bool val) => _uploadingFile.value = val;

  void clearUploaderData() {
    updateUploadProgress(0);
    updateFileToUpload(File(""));
    updateFileToUploadByteMemory(Uint8List(0));
    updateUploadingFile(false);
  }

  reactiveContentFilterService() {
    listenToReactiveValues([_uploadProgress, _fileToUpload, _fileToUploadByteMemory, _uploadingFile]);
  }
}
