library w_transport.src.http.browser.multipart_request;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:http_parser/http_parser.dart' show CaseInsensitiveMap, MediaType;

import 'package:w_transport/src/http/browser/form_data_body.dart';
import 'package:w_transport/src/http/browser/request_mixin.dart';
import 'package:w_transport/src/http/common/request.dart';
import 'package:w_transport/src/http/multipart_file.dart';
import 'package:w_transport/src/http/requests.dart';
import 'package:w_transport/src/http/utils.dart' as http_utils;

class BrowserMultipartRequest extends CommonRequest with BrowserRequestMixin implements MultipartRequest {
  BrowserMultipartRequest() : super();
  BrowserMultipartRequest.withClient(client) : super.withClient(client);

  Map<String, String> _fields = {};

  Map<String, Blob> _files = {};

  @override
  int get contentLength {
    // Let the browser set the content-length.
    return null;
  }

  @override
  set contentLength(int contentLength) {
    throw new UnsupportedError('The content-length of a multipart request cannot be set manually.');
  }

  @override
  MediaType get defaultContentType {
    // Let the browser set the content-type.
    return null;
  }

  Map<String, String> get fields
      => isSent ? new Map.unmodifiable(_fields) : _fields;

  Map<String, dynamic> get files
      => isSent ? new Map.unmodifiable(_files) : _files;

  @override
  Map<String, String> finalizeHeaders() {
    var headers = new CaseInsensitiveMap.from(super.finalizeHeaders());

    // Remove the content-type header to allow the browser to set it.
    headers.remove('content-type');

    return new Map.unmodifiable(headers);
  }

  @override
  Future<FormDataBody> finalizeBody([body]) async {
    if (body != null) {
      throw new UnsupportedError('The body of a Multipart request must be set via `fields` and/or `files`.');
    }

    FormData formData = new FormData();

    // Add each text field.
    fields.forEach((name, value) {
      if (http_utils.isAsciiOnly(value)) {
        formData.append(name, value);
      } else {
        MediaType contentType = new MediaType('text', 'plain', {'charset': UTF8.name});
        Blob blob = new Blob([UTF8.encode(value)], contentType.toString());
        formData.appendBlob(name, blob);
      }
    });
    fields.forEach(formData.append);

    // Add each blob/file.
    List<Future> additions = [];
    files.forEach((name, value) {
      additions.add(() async {
        if (value is Blob) {
          formData.appendBlob(name, value);
        } else if (value is File) {
          formData.appendBlob(name, value, value.name);
        } else if (value is MultipartFile) {
          String contentType = value.contentType != null ? value.contentType.toString() : null;
          Blob blob = new Blob(await value.byteStream.toList(), contentType);
          formData.appendBlob(name, blob, value.filename);
        }
      }());
    });
    await Future.wait(additions);

    return new FormDataBody(formData);
  }
}