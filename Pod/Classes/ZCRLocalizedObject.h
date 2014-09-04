//
//  ZCRLocalizedObject.h
//  ZCRLocalizedObject
//
//  Created by Zachary Radke on 9/3/14.
//
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
 *  Convenience initializer for the ZCRLocalizedObject class.
 */
FOUNDATION_EXPORT ZCRLocalizedObject *ZCRLocalize(NSDictionary *localizedObjectsForLanguageCodes, ZCRLocalizationSpecificity specificity);


/**
 *  A wrapper representing a single object in multiple languages. This wrapper can then be queried for the appropriate localized object for
 *  various languages. The returned value depends both on the backing localization table and the degree of specificity set when initializing
 *  the wrapper.
 *
 *  The class uses a combination of NSLocale's `+preferredLanguages` and NSBundle's `-localizations` to determine a list of possible
 *  languages, ordered by the user's preference. Only languages which belong to this list will function properly.
 */
@interface ZCRLocalizedObject : NSObject

/**
 *  Designated initializer for this class.
 *
 *  @param localizedObjectsForLanguageCodes A dictionary of arbitrary objects set to language code keys. These keys should represent valid
 *                                          language codes that belong to the class' list of possible languages, though their case is
 *                                          irrelevant.
 *  @param specificity                      The specificity of the resulting wrapper when queried.
 *
 *  @return A new wrapper object.
 */
- (instancetype)initWithLocalizationTable:(NSDictionary *)localizedObjectsForLanguageCodes
                              specificity:(ZCRLocalizationSpecificity)specificity;

/**
 *  Uses the most preferred language from the class' list of possible languages and attempts to locate a localized object.
 *
 *  @return A localized object if it can be found, or nil if none matched the preferred language.
 */
- (id)localizedObject;

/**
 *  Uses the given language code and attempts to locate a localized object.
 *
 *  @param languageCode A valid language code which exists as part of the class' possible languages, though the case is irrelevant.
 *
 *  @return A localized object if it can be found, or nil if none matched the given language code.
 */
- (id)localizedObjectForLanguage:(NSString *)languageCode;

@end
