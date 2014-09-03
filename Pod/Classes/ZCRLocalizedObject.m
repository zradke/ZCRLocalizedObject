//
//  ZCRLocalizedObject.m
//  ZCRLocalizedObject
//
//  Created by Zachary Radke on 9/3/14.
//
//

#import "ZCRLocalizedObject.h"

ZCRLocalizedObject *ZCRLocalize(NSDictionary *localizedObjectsForLanguageCodes, ZCRLocalizationSpecificity specificity)
{
    return [[ZCRLocalizedObject alloc] initWithLocalizationTable:localizedObjectsForLanguageCodes specificity:specificity];
};

static NSArray *ZCRPreferredLanguagesFromBundle(NSBundle *bundle)
{
    NSMutableArray *bundleLanguages = [[bundle localizations] mutableCopy];
    [bundleLanguages removeObject:@"Base"];
    
    NSMutableArray *preferredBundleLanguages = [NSMutableArray array];
    
    while (bundleLanguages.count > 0)
    {
        NSArray *orderedLanguages = [NSBundle preferredLocalizationsFromArray:bundleLanguages];
        [bundleLanguages removeObjectsInArray:orderedLanguages];
        [preferredBundleLanguages addObjectsFromArray:orderedLanguages];
    }
    
    return [preferredBundleLanguages copy];
}

static NSArray *ZCRAllPreferredLanguages()
{
    NSArray *bundleLanguages = ZCRPreferredLanguagesFromBundle([NSBundle mainBundle]);
    NSMutableArray *allLanguages = [[NSLocale preferredLanguages] mutableCopy];
    
    NSInteger languageIndex;
    NSMutableArray *pendingLanguages = [NSMutableArray array];
    for (NSString *language in bundleLanguages)
    {
        languageIndex = [allLanguages indexOfObject:language];
        if (languageIndex == NSNotFound)
        {
            [pendingLanguages addObject:language];
        }
        else
        {
            if (pendingLanguages.count > 0)
            {
                [allLanguages insertObjects:pendingLanguages
                                  atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(languageIndex, pendingLanguages.count)]];
                [pendingLanguages removeAllObjects];
            }
        }
    }
    
    if (pendingLanguages.count > 0)
    {
        [allLanguages addObjectsFromArray:pendingLanguages];
    }
    
    return [allLanguages copy];
}

static NSString *ZCRCanonizeLanguageCode(NSString *languageCode, NSArray *allLanguages)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ==[cd] %@", languageCode];
    return [[allLanguages filteredArrayUsingPredicate:predicate] firstObject];
}

static NSDictionary *ZCRCanonizeLocalizationTable(NSDictionary *rawLocalizationTable)
{
    NSMutableDictionary *localizationTable = [NSMutableDictionary dictionary];
    
    for (NSString *languageCode in rawLocalizationTable)
    {
        NSString *canonizedLanguageCode = ZCRCanonizeLanguageCode(languageCode, ZCRAllPreferredLanguages());
        if (canonizedLanguageCode)
        {
            localizationTable[canonizedLanguageCode] = rawLocalizationTable[languageCode];
        }
    }
    
    return [localizationTable copy];
}

@interface ZCRLocalizedObject ()

@property (strong, nonatomic) NSDictionary *localizationTable;
@property (assign, nonatomic) ZCRLocalizationSpecificity specificity;

@end

@implementation ZCRLocalizedObject

- (instancetype)initWithLocalizationTable:(NSDictionary *)localizedObjectsForLanguageCodes specificity:(ZCRLocalizationSpecificity)specificity
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    _localizationTable = ZCRCanonizeLocalizationTable(localizedObjectsForLanguageCodes);
    _specificity = specificity;
    
    return self;
}

- (id)localizedObject
{
    return [self localizedObjectForLanguage:[ZCRAllPreferredLanguages() firstObject]];
}

- (id)localizedObjectForLanguage:(NSString *)languageCode
{
    return [self _localizedObjectForLanguage:languageCode specificity:self.specificity];
}

- (id)_localizedObjectForLanguage:(NSString *)languageCode specificity:(ZCRLocalizationSpecificity)specificity
{
    NSArray *allLanguages = ZCRAllPreferredLanguages();
    languageCode = ZCRCanonizeLanguageCode(languageCode, allLanguages);
    
    switch (specificity)
    {
        case ZCRLocalizationSpecificityExact:
        {
            return self.localizationTable[languageCode];
            break;
        }
        case ZCRLocalizationSpecificityLanguage:
        {
            return [self _localizedObjectMatchingRootOfLanguage:languageCode possibleLanguages:allLanguages];
            break;
        }
        case ZCRLocalizationSpecificityMostRecent:
        {
            return [self _localizedObjectWithMostRecentLanguagePreferring:languageCode possibleLanguages:allLanguages];
            break;
        }
        default:
            break;
    }
    
    return nil;
}

- (id)_localizedObjectMatchingRootOfLanguage:(NSString *)languageCode possibleLanguages:(NSArray *)possibleLanguages
{
    if (self.localizationTable[languageCode])
    {
        return self.localizationTable[languageCode];
    }
    
    NSString *rootLanguage = [[languageCode componentsSeparatedByString:@"-"] firstObject];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", rootLanguage];
    NSArray *preferredMatchingLanguages = [possibleLanguages filteredArrayUsingPredicate:predicate];
    
    for (NSString *preferredLanguage in preferredMatchingLanguages)
    {
        if (self.localizationTable[preferredLanguage])
        {
            return self.localizationTable[preferredLanguage];
        }
    }
    
    return nil;
}

- (id)_localizedObjectWithMostRecentLanguagePreferring:(NSString *)languageCode possibleLanguages:(NSArray *)possibleLanguages
{
    id localizedObject = [self _localizedObjectMatchingRootOfLanguage:languageCode possibleLanguages:possibleLanguages];
    if (localizedObject)
    {
        return localizedObject;
    }
    
    for (NSString *recentLanguageCode in possibleLanguages)
    {
        localizedObject = [self _localizedObjectMatchingRootOfLanguage:recentLanguageCode possibleLanguages:possibleLanguages];
        if (localizedObject)
        {
            return localizedObject;
        }
    }
    
    return nil;
}

@end
