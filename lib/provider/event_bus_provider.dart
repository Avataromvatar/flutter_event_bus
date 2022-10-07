import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';

abstract class EventProvider implements ChangeNotifier, EventBus {
  factory EventProvider({required EventBus controller}) {
    return BasicEventProvider(controller);
  }
}

class BasicEventProvider with ChangeNotifier implements EventProvider {
  String? get prefix => _controller.prefix;
  EventBus _controller;
  BasicEventProvider(this._controller);
  Type get type => runtimeType;
  @override
  bool contain<T>(String? eventName) {
    return _controller.contain<T>(eventName);
  }

  T? lastEvent<T>({String? eventName, String? prefix}) {
    return _controller.lastEvent<T>(eventName: eventName, prefix: prefix);
  }

  bool send<T>(T event, {String? eventName, String? uuid, String? prefix}) {
    return _controller.send<T>(event, eventName: eventName, uuid: uuid, prefix: prefix);
  }

  Stream<EventDTO<T>>? listenEventDTO<T>({String? eventName, bool repeatLastEvent = false, String? prefix}) {
    bool needNotify = !_controller.contain<T>(eventName);
    var ret = _controller.listenEventDTO<T>(eventName: eventName, repeatLastEvent: repeatLastEvent, prefix: prefix);
    if (needNotify) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => notifyListeners(),
      );
    }
    return ret;
  }

  Stream<T>? listenEvent<T>({String? eventName, bool repeatLastEvent = false, String? prefix}) {
    bool needNotify = !_controller.contain<T>(eventName);
    var ret = _controller.listenEvent<T>(eventName: eventName, repeatLastEvent: repeatLastEvent, prefix: prefix);
    if (needNotify) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => notifyListeners(),
      );
    }
    return ret;
  }

  bool repeat<T>({String? eventName, String? uuid, String? prefix}) {
    return _controller.repeat(eventName: eventName, uuid: uuid, prefix: prefix);
  }
}