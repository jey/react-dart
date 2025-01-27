// ignore_for_file: deprecated_member_use_from_same_package
@TestOn('browser')
@JS()
library hooks_test;

import 'dart:html';

import "package:js/js.dart";
import 'package:react/hooks.dart';
import 'package:react/react.dart' as react;
import 'package:react/react.dart';
import 'package:react/react_client.dart';
import 'package:react/react_dom.dart' as react_dom;
import 'package:react/react_test_utils.dart' as react_test_utils;
import 'package:test/test.dart';

main() {
  setClientConfiguration();

  group('React Hooks: ', () {
    group('useState -', () {
      ReactDartFunctionComponentFactoryProxy UseStateTest;
      DivElement textRef;
      DivElement countRef;
      ButtonElement setButtonRef;
      ButtonElement setWithUpdaterButtonRef;

      setUpAll(() {
        var mountNode = new DivElement();

        UseStateTest = react.registerFunctionComponent((Map props) {
          final text = useStateLazy(() {
            return 'initialValue';
          });
          final count = useState(0);

          return react.div({}, [
            react.div({
              'ref': (ref) {
                textRef = ref;
              },
            }, [
              text.value
            ]),
            react.div({
              'ref': (ref) {
                countRef = ref;
              },
            }, [
              count.value
            ]),
            react.button({
              'onClick': (_) => text.set('newValue'),
              'ref': (ref) {
                setButtonRef = ref;
              },
            }, [
              'Set'
            ]),
            react.button({
              'onClick': (_) => count.setWithUpdater((prev) => prev + 1),
              'ref': (ref) {
                setWithUpdaterButtonRef = ref;
              },
            }, [
              '+'
            ]),
          ]);
        });

        react_dom.render(UseStateTest({}), mountNode);
      });

      tearDownAll(() {
        UseStateTest = null;
      });

      test('initializes state correctly', () {
        expect(countRef.text, '0');
      });

      test('Lazy initializes state correctly', () {
        expect(textRef.text, 'initialValue');
      });

      test('StateHook.set updates state correctly', () {
        react_test_utils.Simulate.click(setButtonRef);
        expect(textRef.text, 'newValue');
      });

      test('StateHook.setWithUpdater updates state correctly', () {
        react_test_utils.Simulate.click(setWithUpdaterButtonRef);
        expect(countRef.text, '1');
      });
    });

    group('useReducer -', () {
      ReactDartFunctionComponentFactoryProxy UseReducerTest;
      DivElement textRef;
      DivElement countRef;
      ButtonElement addButtonRef;
      ButtonElement subtractButtonRef;
      ButtonElement textButtonRef;

      Map reducer(Map state, Map action) {
        switch (action['type']) {
          case 'increment':
            return {...state, 'count': state['count'] + 1};
          case 'decrement':
            return {...state, 'count': state['count'] - 1};
          case 'changeText':
            return {...state, 'text': action['newText']};
          default:
            return state;
        }
      }

      setUpAll(() {
        var mountNode = new DivElement();

        UseReducerTest = react.registerFunctionComponent((Map props) {
          final state = useReducer(reducer, {
            'text': 'initialValue',
            'count': 0,
          });

          return react.div({}, [
            react.div({
              'ref': (ref) {
                textRef = ref;
              },
            }, [
              state.state['text']
            ]),
            react.div({
              'ref': (ref) {
                countRef = ref;
              },
            }, [
              state.state['count']
            ]),
            react.button({
              'onClick': (_) => state.dispatch({'type': 'changeText', 'newText': 'newValue'}),
              'ref': (ref) {
                textButtonRef = ref;
              },
            }, [
              'Set'
            ]),
            react.button({
              'onClick': (_) => state.dispatch({'type': 'increment'}),
              'ref': (ref) {
                addButtonRef = ref;
              },
            }, [
              '+'
            ]),
            react.button({
              'onClick': (_) => state.dispatch({'type': 'decrement'}),
              'ref': (ref) {
                subtractButtonRef = ref;
              },
            }, [
              '-'
            ]),
          ]);
        });

        react_dom.render(UseReducerTest({}), mountNode);
      });

      tearDownAll(() {
        UseReducerTest = null;
      });

      test('initializes state correctly', () {
        expect(countRef.text, '0');
        expect(textRef.text, 'initialValue');
      });

      test('dispatch updates states correctly', () {
        react_test_utils.Simulate.click(textButtonRef);
        expect(textRef.text, 'newValue');

        react_test_utils.Simulate.click(addButtonRef);
        expect(countRef.text, '1');

        react_test_utils.Simulate.click(subtractButtonRef);
        expect(countRef.text, '0');
      });

      group('useReducerLazy', () {
        ButtonElement resetButtonRef;

        Map initializeCount(int initialValue) {
          return {'count': initialValue};
        }

        Map reducer2(Map state, Map action) {
          switch (action['type']) {
            case 'increment':
              return {...state, 'count': state['count'] + 1};
            case 'decrement':
              return {...state, 'count': state['count'] - 1};
            case 'reset':
              return initializeCount(action['payload']);
            default:
              return state;
          }
        }

        setUpAll(() {
          var mountNode = new DivElement();

          UseReducerTest = react.registerFunctionComponent((Map props) {
            final ReducerHook<Map, Map, int> state = useReducerLazy(reducer2, props['initialCount'], initializeCount);

            return react.div({}, [
              react.div({
                'ref': (ref) {
                  countRef = ref;
                },
              }, [
                state.state['count']
              ]),
              react.button({
                'onClick': (_) => state.dispatch({'type': 'reset', 'payload': props['initialCount']}),
                'ref': (ref) {
                  resetButtonRef = ref;
                },
              }, [
                'reset'
              ]),
              react.button({
                'onClick': (_) => state.dispatch({'type': 'increment'}),
                'ref': (ref) {
                  addButtonRef = ref;
                },
              }, [
                '+'
              ]),
              react.button({
                'onClick': (_) => state.dispatch({'type': 'decrement'}),
                'ref': (ref) {
                  subtractButtonRef = ref;
                },
              }, [
                '-'
              ]),
            ]);
          });

          react_dom.render(UseReducerTest({'initialCount': 10}), mountNode);
        });

        tearDownAll(() {
          UseReducerTest = null;
        });

        test('initializes state correctly', () {
          expect(countRef.text, '10');
        });

        test('dispatch updates states correctly', () {
          react_test_utils.Simulate.click(addButtonRef);
          expect(countRef.text, '11');

          react_test_utils.Simulate.click(resetButtonRef);
          expect(countRef.text, '10');

          react_test_utils.Simulate.click(subtractButtonRef);
          expect(countRef.text, '9');
        });
      });
    });

    group('useCallback -', () {
      ReactDartFunctionComponentFactoryProxy UseCallbackTest;
      DivElement deltaRef;
      DivElement countRef;
      ButtonElement incrementWithDepButtonRef;
      ButtonElement incrementNoDepButtonRef;
      ButtonElement incrementDeltaButtonRef;

      setUpAll(() {
        var mountNode = new DivElement();

        UseCallbackTest = react.registerFunctionComponent((Map props) {
          final count = useState(0);
          final delta = useState(1);

          var incrementNoDep = useCallback((_) {
            count.setWithUpdater((prev) => prev + delta.value);
          }, []);

          var incrementWithDep = useCallback((_) {
            count.setWithUpdater((prev) => prev + delta.value);
          }, [delta.value]);

          var incrementDelta = useCallback((_) {
            delta.setWithUpdater((prev) => prev + 1);
          }, []);

          return react.div({}, [
            react.div({
              'ref': (ref) {
                deltaRef = ref;
              },
            }, [
              delta.value
            ]),
            react.div({
              'ref': (ref) {
                countRef = ref;
              },
            }, [
              count.value
            ]),
            react.button({
              'onClick': incrementNoDep,
              'ref': (ref) {
                incrementNoDepButtonRef = ref;
              },
            }, [
              'Increment count no dep'
            ]),
            react.button({
              'onClick': incrementWithDep,
              'ref': (ref) {
                incrementWithDepButtonRef = ref;
              },
            }, [
              'Increment count'
            ]),
            react.button({
              'onClick': incrementDelta,
              'ref': (ref) {
                incrementDeltaButtonRef = ref;
              },
            }, [
              'Increment delta'
            ]),
          ]);
        });

        react_dom.render(UseCallbackTest({}), mountNode);
      });

      tearDownAll(() {
        UseCallbackTest = null;
      });

      test('callback is called correctly', () {
        expect(countRef.text, '0');
        expect(deltaRef.text, '1');

        react_test_utils.Simulate.click(incrementNoDepButtonRef);
        expect(countRef.text, '1');

        react_test_utils.Simulate.click(incrementWithDepButtonRef);
        expect(countRef.text, '2');
      });

      group('after depending state changes,', () {
        setUpAll(() {
          react_test_utils.Simulate.click(incrementDeltaButtonRef);
        });

        test('callback stays the same if state not in dependency list', () {
          react_test_utils.Simulate.click(incrementNoDepButtonRef);
          expect(countRef.text, '3', reason: 'still increments by 1 because delta not in dependency list');
        });

        test('callback stays the same if state not in dependency list', () {
          react_test_utils.Simulate.click(incrementWithDepButtonRef);
          expect(countRef.text, '5', reason: 'increments by 2 because delta updated');
        });
      });
    });

    group('useContext -', () {
      var mountNode = DivElement();
      _ContextProviderWrapper providerRef;
      int currentCount = 0;
      Context testContext;
      Function useContextTestFunctionComponent;

      setUp(() {
        UseContextTestComponent(Map props) {
          final context = useContext(testContext);
          currentCount = context;
          return react.div({
            'key': 'uct1'
          }, [
            react.div({'key': 'uct2'}, ['useContext counter value is ${context}']),
          ]);
        }

        testContext = react.createContext(1, calculateChangedBits);
        useContextTestFunctionComponent =
            react.registerFunctionComponent(UseContextTestComponent, displayName: 'useContextTest');

        react_dom.render(
            ContextProviderWrapper({
              'contextToUse': testContext,
              'mode': 'increment',
              'ref': (ref) {
                providerRef = ref;
              }
            }, [
              useContextTestFunctionComponent({'key': 't1'}, []),
            ]),
            mountNode);
      });

      tearDown(() {
        currentCount = 0;
        testContext = null;
        useContextTestFunctionComponent = null;
        providerRef = null;
      });

      group('updates with the correct values', () {
        test('on first render', () {
          expect(currentCount, 1);
        });

        test('on value updates', () {
          providerRef.increment();
          expect(currentCount, 2);
          providerRef.increment();
          expect(currentCount, 3);
          providerRef.increment();
          expect(currentCount, 4);
        });
      });
    });
  });
}

int calculateChangedBits(currentValue, nextValue) {
  int result = 1 << 1;
  if (nextValue % 2 == 0) {
    result |= 1 << 2;
  }
  return result;
}

ReactDartComponentFactoryProxy2 ContextProviderWrapper = react.registerComponent(() => new _ContextProviderWrapper());

class _ContextProviderWrapper extends react.Component2 {
  get initialState {
    return {'counter': 1};
  }

  increment() {
    this.setState({'counter': state['counter'] + 1});
  }

  render() {
    return react.div({}, [
      props['contextToUse']
          .Provider({'value': props['mode'] == 'increment' ? state['counter'] : props['value']}, props['children'])
    ]);
  }
}
