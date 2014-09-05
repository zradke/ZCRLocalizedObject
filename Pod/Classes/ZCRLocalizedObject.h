//
//  ZCRLocalizedObject.h
//  ZCRLocalizedObject
//
//  Created by Zachary Radke on 9/3/14.
//  Copyright (c) 2014 Zach Radke. All rights reserved.
//

@import Foundation;

/**
 *  Enumeration for the specificity of ZCRLocalizedObject's localization.
 */
typedef NS_ENUM(NSInteger, ZCRLocalizationSpecificity)
{
    /**
     *  Requires the given language code to exactly match the localization table in both language and region.
     */
    ZCRLocalizationSpecificityExact,
    
    /**
     *  Requires the given language to have one member (either the root language or a regional variant) in the localization table.
     */
    ZCRLocalizationSpecificityLanguage,
    
    /**
     *  Requires the given language code or one of the other preferred languages have a member in the localization table.
     */
    ZCRLocalizationSpecificityMostRecent
};

@class ZCRLocalizedObject;


/**
 *  Convenience initializer for the ZCRLocalizedObject class, using ZCRLocalizationSpecificityMostRecent, no desired language, and no
 *  default object.
 */
FOUNDATION_EXPORT ZCRLocalizedObject *ZCRLocalize(NSDictionary *localizedObjectsForLanguageCodes);


/**
 *  A proxy representing a single object available in multiple languages. The localization returned depends on a combination of the
 *  proxy's specificity and languageCode property or, in its absence, the most recent preferred language. The proxies are immutable, and
 *  will lazily load the localizedObject property on first access.
 *
 *  Since instances are proxied objects, any unknown message will be directed towards the localizedObject, whatever it may be. Note that
 *  due to this behavior, the proxy may behave as nil if no matching object could be found. For isEqual: and the hash methods, instances
 *  defer to the localizedObject.
 *
 *  The possible languages available to the proxy are a combination of [NSLocale preferredLanguages], [NSBundle localizations], and any
 *  provided languages in the localization table.
 */
@interface ZCRLocalizedObject : NSProxy

/**
 *  Designated initializer for this class.
 *
 *  @param localizedObjectsForLanguageCodes Dictionary of arbitrary objects mapped to language code keys.
 *  @param specificity                      The desired specificity of the resulting localization.
 *  @param desiredLanguageCode              A specific desired language code to try and localize for. If nil, the class will use the
 *                                          device's preferred languages.
 *  @param defaultObject                    A default object that is returned when no other localization can be found. This may be nil.
 *
 *  @return A new proxy representing a localized object.
 */
- (instancetype)initWithLocalizationTable:(NSDictionary *)localizedObjectsForLanguageCodes
                              specificity:(ZCRLocalizationSpecificity)specificity
                          desiredLanguage:(NSString *)desiredLanguageCode
                            defaultObject:(id)defaultObject;

/**
 *  Returns a localized object matching the requirements of the proxy, or nil if none could be found.
 */
@property (strong, nonatomic, readonly) id localizedObject;

/**
 *  Pass this block a specificity to get a copy of the receiver with the updated specificity.
 */
@property (strong, nonatomic, readonly) ZCRLocalizedObject *(^withSpecificity)(ZCRLocalizationSpecificity specificity);

/**
 *  Pass this block a desired language code to get a copy of the receiver with the updated desired language code.
 */
@property (strong, nonatomic, readonly) ZCRLocalizedObject *(^inLanguage)(NSString *desiredLanguageCode);

/**
 *  Pass this block a default object to get a copy of the receiver with the updated default object.
 */
@property (strong, nonatomic, readonly) ZCRLocalizedObject *(^withDefault)(id defaultObject);

@end
