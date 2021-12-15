// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepetitionAdapter extends TypeAdapter<Repetition> {
  @override
  final int typeId = 2;

  @override
  Repetition read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Repetition.Once;
      case 1:
        return Repetition.Daily;
      case 2:
        return Repetition.MonToFri;
      case 3:
        return Repetition.Weekends;
      case 4:
        return Repetition.Custom;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, Repetition obj) {
    switch (obj) {
      case Repetition.Once:
        writer.writeByte(0);
        break;
      case Repetition.Daily:
        writer.writeByte(1);
        break;
      case Repetition.MonToFri:
        writer.writeByte(2);
        break;
      case Repetition.Weekends:
        writer.writeByte(3);
        break;
      case Repetition.Custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepetitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 0;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      timeOfDay: fields[1] as String,
      repetition: fields[2] as Repetition,
      customMessage: fields[3] as String,
      days: (fields[4] as List)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timeOfDay)
      ..writeByte(2)
      ..write(obj.repetition)
      ..writeByte(3)
      ..write(obj.customMessage)
      ..writeByte(4)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookReminderDataAdapter extends TypeAdapter<BookReminderData> {
  @override
  final int typeId = 1;

  @override
  BookReminderData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookReminderData(
      bookId: fields[0] as String,
      reminders: (fields[1] as List)?.cast<Reminder>(),
    );
  }

  @override
  void write(BinaryWriter writer, BookReminderData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.bookId)
      ..writeByte(1)
      ..write(obj.reminders);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookReminderDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
