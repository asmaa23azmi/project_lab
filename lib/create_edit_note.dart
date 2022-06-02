import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'Note_class.dart';
import 'more_options.dart';

// ignore: must_be_immutable
class CreateEditNote extends StatefulWidget {
  int? noteId;
  CreateEditNote(this.noteId, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _NoteState createState() => _NoteState(noteId);
}

class _NoteState extends State<CreateEditNote> {
  int? noteId;
  String _title = "";
  String _content = "";
  String _dateTime = "";
  Color _noteColor = const Color.fromARGB(255, 189, 28, 204);

  _NoteState(this.noteId); //recieves 0 to create new note or note id to edit

  void _saveNote() {
    //when pressing the save icon
    setState(() {
      String color = _noteColor.toString();
      color = color.substring(6, color.length - 1); //hex code
      var dateTime = DateTime.now();
      String formattedDate = DateFormat('EEE MMM dd kk:mm:ss').format(dateTime);
      if (noteId == 0) {
        NoteClass(
            _title, _content, int.parse(color), formattedDate); //add new note
      } else {
        var note =
            NoteClass.getNoteById(noteId)!; //get the note that has thid id
        //edit its content
        note.setTitle = _title;
        note.setColor = int.parse(color);
        note.setContent = _content;
        note.setDate = formattedDate;
        NoteClass.updateNoteInDB(note);
      }
      //after changes navigates to the home page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  bool isSetColor = false; //to keep set color

  void setColor(Color color) {
    //when choosing color from color slider
    setState(() {
      _noteColor = color; //chanage note color
      isSetColor = true;
      //to keep changes of title and content if we change them befor choosing color
      //and before saving them,
      //because choosing color may refill the field with default values
    });
  }

  @override
  Widget build(BuildContext context) {
    if (noteId != 0 && !isSetColor) {
      //get note information to edit
      var note = NoteClass.getNoteById(noteId)!;
      _title = note.getTitle;
      _content = note.getContent;
      _noteColor = Color(note.getColor);
      _dateTime = note.getDate;
    }

    //print('note id is $noteId');

    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: _noteColor,
      foregroundColor: const Color.fromARGB(255, 44, 42, 42),
      //title according to id
      title: Text(noteId == 0 ? 'New Note' : 'Edit Note'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () {
              //to show more options(delete, duplicate, share, color)
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) =>
                    MoreOptions(noteId, setColor),
              );
            },
            child: const Icon(Icons.more_vert),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () async {
              //to save chanes, either add new note or edit it
              if (_title.isNotEmpty || _content.isNotEmpty) {
                _saveNote();
              }
            },
            child: const Icon(Icons.save),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: _noteTitle(context),
            ),
            Flexible(
              child: _noteContent(context),
            ),
            const SizedBox(height: 20),
            noteId == 0 ? Container() : _lastEditDate(context, _dateTime),
          ],
        ),
        top: false, //to allow system intrusion
        bottom: false, //to allow system intrusion
      ),
    );
  }

  Widget _noteTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        onChanged: (str) {
          _title = str;
        },
        decoration: const InputDecoration(
          hintText: 'Type title...',
          counter: SizedBox.shrink(),
        ),
        autofocus: true,
        maxLength: 50,
        style: const TextStyle(
          color: Color.fromARGB(255, 189, 28, 204),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        cursorColor: const Color.fromARGB(255, 189, 28, 204),
        controller: TextEditingController(
            text: noteId == 0 && !isSetColor ? '' : _title),
        focusNode: FocusNode(),
      ),
    );
  }

  Widget _noteContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        onChanged: (str) {
          _content = str;
        },
        decoration: const InputDecoration(
          hintText: 'Type content...',
        ),
        keyboardType: TextInputType.multiline,
        maxLines: 10, // line limit extendable later
        controller: TextEditingController(
            text: noteId == 0 && !isSetColor ? '' : _content),
        focusNode: FocusNode(),
        style: const TextStyle(
          color: Color.fromARGB(255, 88, 80, 79),
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        cursorColor: const Color.fromARGB(255, 6, 47, 80),
      ),
    );
  }

  Widget _lastEditDate(BuildContext context, String _dateTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'last edit at ',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          _dateTime,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}
