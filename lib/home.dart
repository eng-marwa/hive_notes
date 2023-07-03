import 'package:f14/utils/date_time_manager.dart';
import 'package:f14/utils/ext.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'model/Note.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();
  GlobalKey<FormState> _globalKey = GlobalKey();
  GlobalKey<FormState> _updateKey = GlobalKey();
  late Box<Note> box;

  @override
  Widget build(BuildContext context) {
    box = Hive.box<Note>('notes');
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Form(
              key: _globalKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    validator: (value) =>
                        value!.isEmpty ? 'this field is required' : null,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextFormField(
                    controller: _bodyController,
                    validator: (value) =>
                        value!.isEmpty ? 'this field is required' : null,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(labelText: 'Body'),
                  ),
                  //hona
                  ElevatedButton(
                      onPressed: () {
                        if (_globalKey.currentState!.validate()) {
                          Note n = Note(
                              _titleController.value.text,
                              _bodyController.value.text,
                              DateTimeManager.getCurrentDateTime());
                          saveNote(n);
                        }
                      },
                      child: Text('Add Note'))
                ],
              )),
          ValueListenableBuilder<Box<Note>>(
              valueListenable: box.listenable(),
              builder: (context, noteBox, child) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: noteBox.values.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(noteBox.getAt(index)!.title!),
                            Text(noteBox.getAt(index)!.body!),
                          ]),
                      subtitle: Text(noteBox.getAt(index)!.date!),
                      leading: const Icon(
                        Icons.notes,
                        color: Colors.blue,
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(children: [
                          IconButton(
                              onPressed: () {
                                _showEditSheet(context, noteBox, index);
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.green,
                              )),
                          IconButton(
                              onPressed: () {
                                noteBox.deleteAt(index);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              )),
                        ]),
                      ),
                    );
                  }))
        ]),
      ),
    );
  }

  void _showEditSheet(BuildContext context, Box<Note> noteBox, int index) {
    TextEditingController _updateTitle =
        TextEditingController(text: noteBox.getAt(index)!.title);
    TextEditingController _updateBody =
        TextEditingController(text: noteBox.getAt(index)!.body);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Wrap(children: [
              const Center(
                child: Text('Update Note'),
              ),
              Form(
                  key: _updateKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _updateTitle,
                        validator: (value) =>
                            value!.isEmpty ? 'this field is required' : null,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      TextFormField(
                        controller: _updateBody,
                        validator: (value) =>
                            value!.isEmpty ? 'this field is required' : null,
                        minLines: 2,
                        maxLines: 5,
                        decoration: const InputDecoration(labelText: 'Body'),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (_updateKey.currentState!.validate()) {
                              var note = noteBox.getAt(index)!;
                              note.title = _updateTitle.value.text;
                              note.body = _updateBody.value.text;
                              noteBox.putAt(index, note);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Update Note'))
                    ],
                  ))
            ]),
          ),
        ),
      ),
    );
  }

  void saveNote(Note n) {
    box.add(n).then((value) {
      widget.showSnackBar(context, 'Note Added Successfully');
      _titleController.text = '';
      _bodyController.text = '';
    });
  }
}
