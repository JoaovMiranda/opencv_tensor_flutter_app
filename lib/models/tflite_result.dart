class TFLiteResult {
  double confidence;
  int id;
  String label;
  // Based in document TFlite
  TFLiteResult(this.confidence, this.id, this.label);
  
  TFLiteResult.fromModel(dynamic model) {
    confidence = model['confidence'];
    id = model['index'];
    label = model['label'];
  }
}
