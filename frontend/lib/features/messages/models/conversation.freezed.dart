// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return _Conversation.fromJson(json);
}

/// @nodoc
mixin _$Conversation {
  String get id => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  @JsonKey(name: 'participant_names')
  Map<String, String> get participantNames =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'participant_avatars')
  Map<String, String> get participantAvatars =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message')
  String get lastMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_time')
  DateTime get lastMessageTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_counts')
  Map<String, int> get unreadCounts => throw _privateConstructorUsedError;

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
          Conversation value, $Res Function(Conversation) then) =
      _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call(
      {String id,
      List<String> participants,
      @JsonKey(name: 'participant_names') Map<String, String> participantNames,
      @JsonKey(name: 'participant_avatars')
      Map<String, String> participantAvatars,
      @JsonKey(name: 'last_message') String lastMessage,
      @JsonKey(name: 'last_message_time') DateTime lastMessageTime,
      @JsonKey(name: 'unread_counts') Map<String, int> unreadCounts});
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? participants = null,
    Object? participantNames = null,
    Object? participantAvatars = null,
    Object? lastMessage = null,
    Object? lastMessageTime = null,
    Object? unreadCounts = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantNames: null == participantNames
          ? _value.participantNames
          : participantNames // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      participantAvatars: null == participantAvatars
          ? _value.participantAvatars
          : participantAvatars // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      lastMessage: null == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessageTime: null == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unreadCounts: null == unreadCounts
          ? _value.unreadCounts
          : unreadCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
          _$ConversationImpl value, $Res Function(_$ConversationImpl) then) =
      __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<String> participants,
      @JsonKey(name: 'participant_names') Map<String, String> participantNames,
      @JsonKey(name: 'participant_avatars')
      Map<String, String> participantAvatars,
      @JsonKey(name: 'last_message') String lastMessage,
      @JsonKey(name: 'last_message_time') DateTime lastMessageTime,
      @JsonKey(name: 'unread_counts') Map<String, int> unreadCounts});
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
      _$ConversationImpl _value, $Res Function(_$ConversationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? participants = null,
    Object? participantNames = null,
    Object? participantAvatars = null,
    Object? lastMessage = null,
    Object? lastMessageTime = null,
    Object? unreadCounts = null,
  }) {
    return _then(_$ConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantNames: null == participantNames
          ? _value._participantNames
          : participantNames // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      participantAvatars: null == participantAvatars
          ? _value._participantAvatars
          : participantAvatars // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      lastMessage: null == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessageTime: null == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unreadCounts: null == unreadCounts
          ? _value._unreadCounts
          : unreadCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationImpl implements _Conversation {
  const _$ConversationImpl(
      {required this.id,
      required final List<String> participants,
      @JsonKey(name: 'participant_names')
      required final Map<String, String> participantNames,
      @JsonKey(name: 'participant_avatars')
      required final Map<String, String> participantAvatars,
      @JsonKey(name: 'last_message') required this.lastMessage,
      @JsonKey(name: 'last_message_time') required this.lastMessageTime,
      @JsonKey(name: 'unread_counts')
      required final Map<String, int> unreadCounts})
      : _participants = participants,
        _participantNames = participantNames,
        _participantAvatars = participantAvatars,
        _unreadCounts = unreadCounts;

  factory _$ConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationImplFromJson(json);

  @override
  final String id;
  final List<String> _participants;
  @override
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  final Map<String, String> _participantNames;
  @override
  @JsonKey(name: 'participant_names')
  Map<String, String> get participantNames {
    if (_participantNames is EqualUnmodifiableMapView) return _participantNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_participantNames);
  }

  final Map<String, String> _participantAvatars;
  @override
  @JsonKey(name: 'participant_avatars')
  Map<String, String> get participantAvatars {
    if (_participantAvatars is EqualUnmodifiableMapView)
      return _participantAvatars;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_participantAvatars);
  }

  @override
  @JsonKey(name: 'last_message')
  final String lastMessage;
  @override
  @JsonKey(name: 'last_message_time')
  final DateTime lastMessageTime;
  final Map<String, int> _unreadCounts;
  @override
  @JsonKey(name: 'unread_counts')
  Map<String, int> get unreadCounts {
    if (_unreadCounts is EqualUnmodifiableMapView) return _unreadCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_unreadCounts);
  }

  @override
  String toString() {
    return 'Conversation(id: $id, participants: $participants, participantNames: $participantNames, participantAvatars: $participantAvatars, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime, unreadCounts: $unreadCounts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            const DeepCollectionEquality()
                .equals(other._participantNames, _participantNames) &&
            const DeepCollectionEquality()
                .equals(other._participantAvatars, _participantAvatars) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTime, lastMessageTime) ||
                other.lastMessageTime == lastMessageTime) &&
            const DeepCollectionEquality()
                .equals(other._unreadCounts, _unreadCounts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_participants),
      const DeepCollectionEquality().hash(_participantNames),
      const DeepCollectionEquality().hash(_participantAvatars),
      lastMessage,
      lastMessageTime,
      const DeepCollectionEquality().hash(_unreadCounts));

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationImplToJson(
      this,
    );
  }
}

abstract class _Conversation implements Conversation {
  const factory _Conversation(
      {required final String id,
      required final List<String> participants,
      @JsonKey(name: 'participant_names')
      required final Map<String, String> participantNames,
      @JsonKey(name: 'participant_avatars')
      required final Map<String, String> participantAvatars,
      @JsonKey(name: 'last_message') required final String lastMessage,
      @JsonKey(name: 'last_message_time')
      required final DateTime lastMessageTime,
      @JsonKey(name: 'unread_counts')
      required final Map<String, int> unreadCounts}) = _$ConversationImpl;

  factory _Conversation.fromJson(Map<String, dynamic> json) =
      _$ConversationImpl.fromJson;

  @override
  String get id;
  @override
  List<String> get participants;
  @override
  @JsonKey(name: 'participant_names')
  Map<String, String> get participantNames;
  @override
  @JsonKey(name: 'participant_avatars')
  Map<String, String> get participantAvatars;
  @override
  @JsonKey(name: 'last_message')
  String get lastMessage;
  @override
  @JsonKey(name: 'last_message_time')
  DateTime get lastMessageTime;
  @override
  @JsonKey(name: 'unread_counts')
  Map<String, int> get unreadCounts;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
