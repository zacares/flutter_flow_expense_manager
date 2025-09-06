import "package:flow/entity/_base.dart";
import "package:flow/entity/transaction/tag_type.dart";
import "package:flow/utils/json/utc_datetime_converter.dart";
import "package:json_annotation/json_annotation.dart";
import "package:objectbox/objectbox.dart";

part "transaction_tag.g.dart";

@Entity()
@JsonSerializable(explicitToJson: true, converters: [UTCDateTimeConverter()])
class TransactionTag extends EntityBase {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int id;

  @override
  @Unique()
  String uuid;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  bool? isDeleted;

  @Property(type: PropertyType.date)
  DateTime? deletedDate;

  static const int maxTitleLength = 96;

  String? title;

  @Transient()
  TransactionTagType get tagType => TransactionTagType.fromString(type);

  /// Type of tag, e.g., generic, location, contact, etc.
  ///
  /// See [TransactionTagType] for possible values.
  String? type;

  String? payload;

  TransactionTag({
    this.id = 0,
    required this.uuid,
    DateTime? createdDate,
    this.isDeleted,
    this.deletedDate,
    this.title,
    this.type,
    this.payload,
  }) : createdDate = createdDate ?? DateTime.now();
}
