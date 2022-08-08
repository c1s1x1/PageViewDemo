import 'dart:async';

const Duration _kDuration = Duration(milliseconds: 400);

class PreventRepeatedEvent {
  final StreamController _controller = StreamController();
  late StreamSubscription _subscription;
  Timer? _timer;

  void addEventListener(void Function(dynamic data) dataCall) {
    _subscription = _controller.stream.listen((event) {
      dataCall(event);
    });
  }

  void sendEvent(dynamic data) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(_kDuration, () {
      if(!_controller.isClosed){
        _controller.add(data);
      }
    });
  }

  void cancel() {
    _controller.close();
    _subscription.cancel();
  }
}