import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/utils/logger.dart';
import 'package:logging/logging.dart' as logging;
import 'package:test/test.dart';

void main() {
  group('DartLLMLogger', () {
    setUp(() {
      DartLLMLogger.configure(enabled: false, level: LogLevel.warning);
      logging.Logger.root.clearListeners();
    });

    group('configure', () {
      test('enables logging when enabled is true', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.info);

        expect(DartLLMLogger.isEnabled, isTrue);
        expect(DartLLMLogger.minLevel, equals(LogLevel.info));
      });

      test('disables logging when enabled is false', () {
        DartLLMLogger.configure(enabled: false, level: LogLevel.debug);

        expect(DartLLMLogger.isEnabled, isFalse);
      });

      test('sets root logger level to OFF when disabled', () {
        DartLLMLogger.configure(enabled: false, level: LogLevel.debug);

        expect(logging.Logger.root.level, equals(logging.Level.OFF));
      });

      test('maps LogLevel.error to Level.SEVERE', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.error);

        expect(logging.Logger.root.level, equals(logging.Level.SEVERE));
      });

      test('maps LogLevel.warning to Level.WARNING', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.warning);

        expect(logging.Logger.root.level, equals(logging.Level.WARNING));
      });

      test('maps LogLevel.info to Level.INFO', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.info);

        expect(logging.Logger.root.level, equals(logging.Level.INFO));
      });

      test('maps LogLevel.debug to Level.FINE', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.debug);

        expect(logging.Logger.root.level, equals(logging.Level.FINE));
      });
    });

    group('logging methods', () {
      test('creates logger with specified name', () {
        final logger = DartLLMLogger('dartllm.test');

        expect(logger.underlying.fullName, equals('dartllm.test'));
      });

      test('debug logs when enabled and level is debug', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.debug);
        final logger = DartLLMLogger('dartllm.test');
        final records = <logging.LogRecord>[];
        logging.Logger.root.onRecord.listen(records.add);

        logger.debug('Debug message');

        expect(records, hasLength(1));
        expect(records.first.level, equals(logging.Level.FINE));
        expect(records.first.message, equals('Debug message'));
      });

      test('debug does not log when level is above debug', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.info);
        final logger = DartLLMLogger('dartllm.test');
        final records = <logging.LogRecord>[];
        logging.Logger.root.onRecord.listen(records.add);

        logger.debug('Debug message');

        expect(records, isEmpty);
      });

      test('info logs when enabled and level is info or below', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.info);
        final logger = DartLLMLogger('dartllm.test');
        final records = <logging.LogRecord>[];
        logging.Logger.root.onRecord.listen(records.add);

        logger.info('Info message');

        expect(records, hasLength(1));
        expect(records.first.level, equals(logging.Level.INFO));
      });

      test('warning logs when enabled and level is warning or below', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.warning);
        final logger = DartLLMLogger('dartllm.test');
        final records = <logging.LogRecord>[];
        logging.Logger.root.onRecord.listen(records.add);

        logger.warning('Warning message');

        expect(records, hasLength(1));
        expect(records.first.level, equals(logging.Level.WARNING));
      });

      test('error always logs when enabled', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.error);
        final logger = DartLLMLogger('dartllm.test');
        final records = <logging.LogRecord>[];
        logging.Logger.root.onRecord.listen(records.add);

        logger.error('Error message');

        expect(records, hasLength(1));
        expect(records.first.level, equals(logging.Level.SEVERE));
      });

      test('error includes error object and stack trace', () {
        DartLLMLogger.configure(enabled: true, level: LogLevel.error);
        final logger = DartLLMLogger('dartllm.test');
        final records = <logging.LogRecord>[];
        logging.Logger.root.onRecord.listen(records.add);
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        logger.error('Error occurred', error, stackTrace);

        expect(records, hasLength(1));
        expect(records.first.error, equals(error));
        expect(records.first.stackTrace, equals(stackTrace));
      });

      test('does not log when disabled', () {
        DartLLMLogger.configure(enabled: false, level: LogLevel.debug);
        final logger = DartLLMLogger('dartllm.test');
        final records = <logging.LogRecord>[];
        logging.Logger.root.onRecord.listen(records.add);

        logger.debug('Debug');
        logger.info('Info');
        logger.warning('Warning');
        logger.error('Error');

        expect(records, isEmpty);
      });
    });

    group('underlying', () {
      test('provides access to raw logger', () {
        final logger = DartLLMLogger('dartllm.test.raw');

        expect(logger.underlying, isA<logging.Logger>());
        expect(logger.underlying.fullName, equals('dartllm.test.raw'));
      });
    });
  });
}
