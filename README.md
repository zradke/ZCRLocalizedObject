# ZCRLocalizedObject

[![CI Status](http://img.shields.io/travis/zradke/ZCRLocalizedObject.svg?style=flat)](https://travis-ci.org/zradke/ZCRLocalizedObject)
[![Version](https://img.shields.io/cocoapods/v/ZCRLocalizedObject.svg?style=flat)](http://cocoadocs.org/docsets/ZCRLocalizedObject)
[![License](https://img.shields.io/cocoapods/l/ZCRLocalizedObject.svg?style=flat)](http://cocoadocs.org/docsets/ZCRLocalizedObject)
[![Platform](https://img.shields.io/cocoapods/p/ZCRLocalizedObject.svg?style=flat)](http://cocoadocs.org/docsets/ZCRLocalizedObject)

Dynamically localized objects that just work.

## Getting started

Assuming you have some localized data being dynamically served:

```
{
  "en": "Hello",
  "en-GB": "Good day",
  "en-US": "Howdy",
  "fr": "Bonjour"
}
```

Create a ZCRLocalizedObject from it:

```
ZCRLocalizedObject *object = ZCRLocalize(localizedData, ZCRLocalizedSpecificityMostRecent);
```

Then retrieve the localized value:

```
// Device language set to 'British English'
object.localizedObject; // @"Good day"
```

## Specificity

You can also specify how exactly you want the localization to work using the different specificity values.

### ZCRLocalizedObjectSpecificityExact

Requires the language and region to match exactly, otherwise returns nil.

```
NSDictionary *localizedData = @{@"en-GB": @"The colour",
                                @"en": @"The color"};
                  
ZCRLocalizedObject *object = ZCRLocalize(localizedData, ZCRLocalizedObjectSpecificityExact);

// Device set to 'English'
object.localizedObject; // nil

// Device set to 'British English'
object.localizedObject; // @"The colour" 
```

### ZCRLocalizedObjectSpecificityLanguage

Checks for an exact match, then checks for a match with based on the root language and any other present regions before returning nil.

```
NSDictionary *localizedData = @{@"en": @"The color"};

ZCRLocalizedObject *object = ZCRLocalize(localizedData, ZCRLocalizedObjectSpecificityLanguage);

// Device set to 'British English'
object.localizedObject; // @"The color" 
```

### ZCRLocalizedObjectSpecificityMostRecent

Checks for an exact match, then a language match, then goes through all possible languages in order of preference to locate a match following the same pattern of exact and language matches before returning nil.

```
NSDictionary *localizedData = @{@"fr": @"La couleur"};
                  
ZCRLocalizedObject *object = ZCRLocalize(localizedData, ZCRLocalizedObjectSpecificityMostRecent);

// Device set to 'French' then 'English'
object.localizedObject; // @"La couleur" 
```

## Installation

ZCRLocalizedObject is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "ZCRLocalizedObject"

## Author

Zach Radke, zach.radke@gmail.com

## License

ZCRLocalizedObject is available under the MIT license. See the LICENSE file for more info.

