import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../user_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);
  @override
  _EditableTableState createState() => _EditableTableState();
}

class _EditableTableState extends State<StatsScreen> {
  List<Map<String, dynamic>> _tableData = [];
  List<List<bool>> _editState = [];
  List<TextEditingController> _controllers = [];
  String user = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      user = Provider.of<UserProvider>(context).user;
    });
    print('User: $user');
    _fetchData();
  }

  Future<void> _fetchData() async {
    final String apiUrl = '${dotenv.env['API_URL']!}/getStats';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'user': user,
        }),
      );
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          _tableData = List.generate(data['dates'].length, (index) {
            return {
              'date': data['dates'][index],
              'weight': data['weight'][index].toString(),
              'height': data['height'][index].toString(),
              'fat': data['fat'][index].toString(),
              'cals': data['cals'][index].toString(),
              'idstats': data['idstats'][index].toString(),
              'idcals': data['idcals'][index].toString(),
            };
          });

          _editState = List.generate(_tableData.length, (index) {
            return [false, false, false, false]; // weight, height, fat, cals are editable
          });

          _controllers = List.generate(_tableData.length * 4, (index) => TextEditingController());
        });
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteRow(int index) async {
    final String apiUrl = '${dotenv.env['API_URL']!}/deleteStat';
    print('Deleting data: ${_tableData[index]}');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'user': user,
          'data': _tableData[index],
        }),
      );
      print('User: $user');
      print('Delete Response: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          _tableData.removeAt(index);
          _editState.removeAt(index);
          _controllers.removeRange(index * 4, (index + 1) * 4);
        });
      } else {
        print('Failed to delete data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _saveTable() async {
    final String apiUrl = '${dotenv.env['API_URL']!}/saveStats';
    print('Saving data: $_tableData');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'user': user,
          'data': _tableData,
        }),
      );
      print('Save Response: ${response.body}');
      if (response.statusCode == 200) {
        print('Data saved successfully');
      } else {
        print('Failed to save data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTable,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _tableData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: _buildDataColumns(),
                  rows: _buildDataRows(),
                ),
              ),
      ),
    );
  }

  List<DataColumn> _buildDataColumns() {
    return [
      DataColumn(label: Text('Weight')),
      DataColumn(label: Text('Height')),
      DataColumn(label: Text('Fat')),
      DataColumn(label: Text('Cals')),
      DataColumn(label: Text('Date')),
      DataColumn(label: Text('Actions')),
    ];
  }

  List<DataRow> _buildDataRows() {
    return List.generate(_tableData.length, (rowIndex) {
      return DataRow(cells: _buildDataCells(rowIndex));
    });
  }

  List<DataCell> _buildDataCells(int rowIndex) {
    return [
      _buildEditableCell(rowIndex, 0, _tableData[rowIndex]['weight']),
      _buildEditableCell(rowIndex, 1, _tableData[rowIndex]['height']),
      _buildEditableCell(rowIndex, 2, _tableData[rowIndex]['fat']),
      _buildEditableCell(rowIndex, 3, _tableData[rowIndex]['cals']),
      DataCell(Text(_tableData[rowIndex]['date'])),
      DataCell(
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _deleteRow(rowIndex),
        ),
      ),
    ];
  }

  DataCell _buildEditableCell(int rowIndex, int colIndex, String text) {
    final int controllerIndex = rowIndex * 4 + colIndex;
    return DataCell(
      _editState[rowIndex][colIndex]
          ? TextField(
              controller: _controllers[controllerIndex]..text = text,
              onSubmitted: (value) {
                setState(() {
                  _tableData[rowIndex][_getColumnKey(colIndex)] = value;
                  _editState[rowIndex][colIndex] = false;
                });
              },
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  _editState[rowIndex][colIndex] = true;
                });
              },
              child: Text(text),
            ),
    );
  }

  String _getColumnKey(int colIndex) {
    switch (colIndex) {
      case 0:
        return 'weight';
      case 1:
        return 'height';
      case 2:
        return 'fat';
      case 3:
        return 'cals';
      default:
        return '';
    }
  }
}
