//
//  ZCRLocalizedObject.h
//  ZCRLocalizedObject
//
//  Created by Zachary Radke on 9/3/14.
//
//

@import Foundation;

typedef NS_ENUM(NSInteger, ZCRLocalizationSpecificity)
{
    ZCRLocalizationSpecificityExact,
    ZCRLocalizationSpecificityLanguage,
    ZCRLocalizationSpecificityMostRecent
};

@class ZCRLocalizedObject;

FOUNDATION_EXPORT ZCRLocalizedObject *ZCRLocalize(NSDictionary *localizedObjectsForLanguageCodes, ZCRLocalizationSpecificity specificity);

@interface ZCRLocalizedObject : NSObject

- (instancetype)initWithLocalizationTable:(NSDictionary *)localizedObjectsForLanguageCodes
                              specificity:(ZCRLocalizationSpecificity)specificity;

- (id)localizedObject;
- (id)localizedObjectForLanguage:(NSString *)languageCode;

@end
