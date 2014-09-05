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
ZCRLocalizedObject *object = ZCRLocalize(localizedData);
```

Then retrieve the localized value:

```
// Device language set to 'British English'
object.localizedObject; // @"Good day"
```

## Specificity

You can also specify how exactly you want the localization to work using the different specificity values.

### ZCRLocalizationSpecificityExact

Requires the language and region to match exactly, otherwise returns nil.

```
NSDictionary *localizedData = @{@"en-GB": @"The colour",
                                @"en": @"The color"};
                  
ZCRLocalizedObject *object = ZCRLocalize(localizedData).withSpecificity(ZCRLocalizationSpecificityExact);

// Device set to 'English'
object.localizedObject; // nil

// Device set to 'British English'
object.localizedObject; // @"The colour" 
```

### ZCRLocalizationSpecificityLanguage

Checks for an exact match, then checks for a match with based on the root language and any other present regions before returning nil.

```
NSDictionary *localizedData = @{@"en": @"The color"};

ZCRLocalizedObject *object = ZCRLocalize(localizedData);

// Device set to 'British English'
object.localizedObject; // @"The color" 
```

### ZCRLocalizationSpecificityMostRecent

Checks for an exact match, then a language match, then goes through all possible languages in order of preference to locate a match following the same pattern of exact and language matches before returning nil. This is the default specificity for `ZCRLocalize()`.

```
NSDictionary *localizedData = @{@"fr": @"La couleur"};
                  
ZCRLocalizedObject *object = ZCRLocalize(localizedData).withSpecificity(ZCRLocalizationSpecificityMostRecent);

// Device set to 'French' then 'English'
object.localizedObject; // @"La couleur" 
```

## Requesting a language

You can specify a preferred language when creating a ZCRLocalizedObject. If you don't provide a requested language, the device's most recent language will be used instead.

```
NSDictionary *localizedData = @{@"en", @"The color",
                                @"fr": @"La couleur"};

object = ZCRLocalize(localizedData).inLanguage(@"fr");

// Device set to 'English'
object.localizedObject; // @"La couleur"
```

Note that while ZCRLocalizedObject will try to accommodate your language request, it still uses its specificity to determine matches.

## Providing a fallback

If you'd rather not get nil back when no match is found, you can tell ZCRLocalizedObject to return a default value instead.

```
NSDictionary *localizedData = @{@"en", @"The color"};

object = ZCRLocalize(localizedData).withSpecificity(ZCRLocalizationSpecificityLanguage)
object = object.withDefault(@"Unknown!").inLanguage(@"fr");

object.localizedObject; // @"Unknown!"
```

## Proxy power

ZCRLocalizedObject is a subclass of NSProxy, and defers many of its methods to its localizedObject property.

This means you can do things like…

```
NSDictionary *localizedData = @{@"en": @"ALL CAPS?"};

NSString *string = [(id)ZCRLocalize(localizedData) lowercaseString];

// Device set to 'English'
string; // @"all caps?"
```

Or even…

```
NSDictionary *localizedData = @{@"en": @"Hello",
                                @"fr": @"Bonjour"};

id object = ZCRLocalize(localizedData);

// Device set to 'English'
[object isEqual:@"Hello"]; // YES
```

Note that depending on the configuration, the localizedObject may be nil, which will cause exceptions when unknown methods are called on the proxy. For this reason, unless a default value is provided or there is no doubt that a matching localization will be found, it's advisable to first check if the localizedObject is nil before casting the proxy and sending it messages.


## Installation

ZCRLocalizedObject is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "ZCRLocalizedObject"

## Author

Zach Radke, zach.radke@gmail.com

## License

ZCRLocalizedObject is available under the MIT license. See the LICENSE file for more info.

