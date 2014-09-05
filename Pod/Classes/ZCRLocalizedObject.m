//
//  ZCRLocalizedObject.m
//  ZCRLocalizedObject
//
//  Created by Zachary Radke on 9/3/14.
//  Copyright (c) 2014 Zach Radke. All rights reserved.
//

#import "ZCRLocalizedObject.h"

#pragma - Generating Language Lists

static NSString *ZCRStringFromSpecificity(ZCRLocalizationSpecificity specificity)
{
    switch (specificity)
    {
        case ZCRLocalizationSpecificityExact:
            return @"exact match";
        case ZCRLocalizationSpecificityLanguage:
            return @"language member match";
        case ZCRLocalizationSpecificityMostRecent:
            return @"most recent match";
        default:
            return nil;
    }
}

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

static NSArray *ZCRAllPreferredLanguages(NSArray *providedLanguages)
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
    
    NSMutableArray *pendingProvidedLanguages = [providedLanguages mutableCopy];
    [pendingProvidedLanguages removeObjectsInArray:allLanguages];
    
    [allLanguages addObjectsFromArray:pendingProvidedLanguages];
    
    return [allLanguages copy];
}

static NSDictionary *ZCRCanonizeLocalizationTable(NSDictionary *rawLocalizationTable)
{
    NSMutableDictionary *localizationTable = [NSMutableDictionary dictionary];
    
    NSString *canonizedCode;
    for (NSString *languageCode in rawLocalizationTable)
    {
        canonizedCode = [NSLocale canonicalLanguageIdentifierFromString:languageCode];
        localizationTable[canonizedCode] = rawLocalizationTable[languageCode];
    }
    
    return [localizationTable copy];
}


#pragma mark - API

ZCRLocalizedObject *ZCRLocalize(NSDictionary *localizedObjectsForLanguageCodes)
{
    return [[ZCRLocalizedObject alloc] initWithLocalizationTable:localizedObjectsForLanguageCodes
                                                     specificity:ZCRLocalizationSpecificityMostRecent
                                                 desiredLanguage:nil
                                                   defaultObject:nil];
};


@interface ZCRLocalizedObject ()

@property (strong, nonatomic) NSDictionary *localizationTable;
@property (assign, nonatomic) ZCRLocalizationSpecificity specificity;
@property (strong, nonatomic) NSString *desiredLanguage;
@property (strong, nonatomic) id defaultObject;

@property (assign) BOOL didGenerateLocalizedObject;

@end

@implementation ZCRLocalizedObject
@synthesize localizedObject = _localizedObject;

- (instancetype)initWithLocalizationTable:(NSDictionary *)localizedObjectsForLanguageCodes
                              specificity:(ZCRLocalizationSpecificity)specificity
                          desiredLanguage:(NSString *)desiredLanguageCode
                            defaultObject:(id)defaultObject
{
    _localizationTable = ZCRCanonizeLocalizationTable(localizedObjectsForLanguageCodes);
    _specificity = specificity;
    _desiredLanguage = [desiredLanguageCode copy];
    _defaultObject = defaultObject;
    
    return self;
}

- (id)localizedObject
{
    if (!self.didGenerateLocalizedObject)
    {
        _localizedObject = [self _generateLocalizedObject];
        self.didGenerateLocalizedObject = YES;
    }
    
    return _localizedObject;
}

- (ZCRLocalizedObject *(^)(ZCRLocalizationSpecificity))withSpecificity
{
    __weak typeof(self) weakSelf = self;
    return ^ZCRLocalizedObject *(ZCRLocalizationSpecificity specificity) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (specificity == strongSelf.specificity)
        {
            return strongSelf;
        }
        
        return [[[strongSelf class] alloc] initWithLocalizationTable:strongSelf.localizationTable
                                                   specificity:specificity
                                               desiredLanguage:strongSelf.desiredLanguage
                                                       defaultObject:strongSelf.defaultObject];
    };
}

- (ZCRLocalizedObject *(^)(NSString *))inLanguage
{
    __weak typeof(self) weakSelf = self;
    return ^ZCRLocalizedObject *(NSString *desiredLanguageCode) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if ((!desiredLanguageCode && !strongSelf.desiredLanguage) ||
            (desiredLanguageCode && strongSelf.desiredLanguage && [strongSelf.desiredLanguage isEqualToString:desiredLanguageCode]))
        {
            return strongSelf;
        }
        
        return [[[strongSelf class] alloc] initWithLocalizationTable:strongSelf.localizationTable
                                                   specificity:strongSelf.specificity
                                               desiredLanguage:desiredLanguageCode
                                                       defaultObject:strongSelf.defaultObject];
    };
}

- (ZCRLocalizedObject *(^)(id))withDefault
{
    __weak typeof(self) weakSelf = self;
    return ^ZCRLocalizedObject *(id defaultObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (defaultObject == strongSelf.defaultObject)
        {
            return strongSelf;
        }
        
        return [[[strongSelf class] alloc] initWithLocalizationTable:strongSelf.localizationTable
                                                         specificity:strongSelf.specificity
                                                     desiredLanguage:strongSelf.desiredLanguage
                                                       defaultObject:defaultObject];
    };
}


#pragma mark - Localization

- (id)_generateLocalizedObject
{
    NSArray *allLanguages = ZCRAllPreferredLanguages(self.localizationTable.allKeys);
    NSString *languageCode = (self.desiredLanguage.length > 0) ? self.desiredLanguage : allLanguages.firstObject;
    
    id object = [self _localizedObjectForLanguage:languageCode specificity:self.specificity allLanguages:allLanguages];
    return object ?: self.defaultObject;
}

- (id)_localizedObjectForLanguage:(NSString *)languageCode specificity:(ZCRLocalizationSpecificity)specificity allLanguages:(NSArray *)allLanguages
{
    languageCode = [NSLocale canonicalLanguageIdentifierFromString:languageCode];
    
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


#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    return [self.localizedObject isEqual:object];
}

- (NSUInteger)hash
{
    return [self.localizedObject hash];
}

- (NSString *)description
{
    return [self.localizedObject description];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@:%p> specificity: %@, desired language: %@\n%@", [self class], self, ZCRStringFromSpecificity(self.specificity), self.desiredLanguage, self.localizationTable];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
    {
        return YES;
    }
    else
    {
        return [self.localizedObject respondsToSelector:aSelector];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.localizedObject;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [self.localizedObject methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.localizedObject];
}

@end
