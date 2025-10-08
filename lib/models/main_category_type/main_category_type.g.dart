// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_category_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MainCategoryTypeAdapter extends TypeAdapter<MainCategoryType> {
  @override
  final int typeId = 1;

  @override
  MainCategoryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MainCategoryType.needs;
      case 1:
        return MainCategoryType.wants;
      case 2:
        return MainCategoryType.savings;
      case 3:
        return MainCategoryType.investments;
      default:
        return MainCategoryType.needs;
    }
  }

  @override
  void write(BinaryWriter writer, MainCategoryType obj) {
    switch (obj) {
      case MainCategoryType.needs:
        writer.writeByte(0);
        break;
      case MainCategoryType.wants:
        writer.writeByte(1);
        break;
      case MainCategoryType.savings:
        writer.writeByte(2);
        break;
      case MainCategoryType.investments:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainCategoryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
