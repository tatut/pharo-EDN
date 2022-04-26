# pharo-EDN

![test workflow](https://github.com/tatut/pharo-EDN/actions/workflows/test.yml/badge.svg)

Extensible Data Notation library for Pharo Smalltalk

## Quick start guide

```smalltalk
"Reading EDN from a ReadStream"
edn1 := '{:some ["edn"] :data #{:here}}'.
obj := EDNReader new in: (edn1 readStream); read.

"Writing an object as EDN to a WriteStream"
edn2 := String streamContents: [:out |
  EDNWriter new out: out; write: obj ].
```


## Mapping to Smalltalk objects

EDN data is mapped to Smalltalk classes:

- vectors `[]` as `OrderedCollection`
- lists `()` as `LinkedList`
- maps `{}` as `Dictionary`
- sets `#{}` as `Set`
- symbols and keywords as `Symbol`
- strings as `String`
- numbers as `Float` and `Integer`
- characters (like `\space`) as `Character`
- boolean as `Boolean`
- nil as `UndefinedObject`
- `#inst` as `DateAndTime`
- `#uuid` as `UUID`
