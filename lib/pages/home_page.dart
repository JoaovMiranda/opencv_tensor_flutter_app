import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_tensor_flutter/helpers/opencv_helper.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:open_tensor_flutter/helpers/camera_helper.dart';
import 'package:open_tensor_flutter/helpers/tflite_helper.dart';
import 'package:open_tensor_flutter/models/tflite_result.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:opencv/opencv.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic res;

  Image _image;
  File _imageNew;
  File file;

  bool loaded = false;
  bool preloaded = false;

  String dropdownValue = 'None';
  List<TFLiteResult> _outputs = [];
  List<String> _options = [
    'None',
    'blur',
    'GaussianBlur',
    'medianBlur',
    'bilateralFilter',
    'boxFilter',
    'sqrBoxFilter',
    'filter2D',
    'threshold',
    'dilate',
    'erode',
    'morphologyEx',
    'pyrUp',
    'pyrDown',
    'pyrMeanShiftFiltering',
    'adaptiveThreshold',
    'copyMakeBorder',
    'sobel',
    'scharr',
    'laplacian',
    'distanceTransform',
    'resize',
    'applyColorMap',
    'houghCircles'
  ];

  @override
  void initState() {
    super.initState();
    TFLiteHelper.loadModel();
  }

  @override
  void dispose() {
    TFLiteHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('OpenCV + TensorFlow Lite'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[_buildResult(), _buildImage(), _actionsRow()],
        ),
      ),
    );
  }

  _buildImage() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 92.0),
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: _buildResultImage()),
        ),
      ),
    );
  }

  _pickImage(ImageSource source) async {
    file = await CameraHelper.pickImage(source);
    if (file == null) {
      return null;
    }

    setState(() {
      _imageNew = file;
    });

    _classifyImage(file);
    _openClassify(dropdownValue, file);
  }

  _classifyImage(image) async {
    if (image == null) return;
    final outputs = await TFLiteHelper.classifyImage(image);
    setState(() {
      _outputs = outputs;
    });
  }

  _openClassify(String data, File file) async {
    res = await OpenCVHelper.openClassify(data, file);
    setState(() {
      _image = Image.memory(res);
      loaded = true;
    });

//    _classifyImage(File.fromRawPath(res));
  }

  _buildResultImage() {
    if (loaded == false) {
      if (_imageNew == null) {
        return Text('Sem imagem');
      } else {
        return Image.file(_imageNew, fit: BoxFit.cover);
      }
    } else {
      return _image;
    }
  }

  _buildResult() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Container(
        height: 150.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _buildResultList(),
      ),
    );
  }

  _buildResultList() {
    if (_outputs.isEmpty) {
      return Center(
        child: Text('Sem resultados'),
      );
    }

    return Center(
      child: ListView.builder(
        itemCount: _outputs.length,
        shrinkWrap: true,
        padding: const EdgeInsets.all(20.0),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Text(
                '${_outputs[index].label} ( ${(_outputs[index].confidence * 100.0).toStringAsFixed(2)} % ) a',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10.0,
              ),
              LinearPercentIndicator(
                lineHeight: 14.0,
                percent: _outputs[index].confidence,
              ),
            ],
          );
        },
      ),
    );
  }

  _actionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        DropdownButton<String>(
          value: dropdownValue,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          underline: Container(
            color: Colors.grey,
            height: 2,
          ),
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
            });
          },
          items: _options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.image),
                onPressed: () => _pickImage(ImageSource.camera)),
            IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        )
      ],
    );
  }
}
