//
//  ZCRLocalizedObjectTests.m
//  ZCRLocalizedObjectTests
//
//  Created by Zach Radke on 09/03/2014.
//  Copyright (c) 2014 Zach Radke. All rights reserved.
//

#import <ZCRLocalizedObject/ZCRLocalizedObject.h>

SpecBegin(ZCRLocalizedObjectSpecs)

__block id localeClassMock;

__block NSDictionary *localizationTable;
__block ZCRLocalizationSpecificity specificity;

__block ZCRLocalizedObject *localizedObject;


beforeEach(^{
    localeClassMock = OCMClassMock([NSLocale class]);
});

afterEach(^{
    [localeClassMock stopMocking];
    localeClassMock = nil;
});


describe(@"using the device language", ^{
    beforeEach(^{
        specificity = ZCRLocalizationSpecificityMostRecent;
        
        NSArray *preferredLanguages = @[@"en-GB",
                                        @"fr",
                                        @"en",
                                        @"de"];
        OCMStub([localeClassMock preferredLanguages]).andReturn(preferredLanguages);
    });
    
    it(@"should use the top preferred language", ^{
        localizationTable = @{@"en-GB": @"British English",
                              @"en": @"English",
                              @"fr": @"Français"};
        localizedObject = ZCRLocalize(localizationTable, specificity);
        
        expect(localizedObject.localizedObject).to.equal(@"British English");
    });
    
    it(@"should use the top language's root", ^{
        localizationTable = @{@"en": @"English",
                              @"fr": @"Français"};
        localizedObject = ZCRLocalize(localizationTable, specificity);
        
        expect(localizedObject.localizedObject).to.equal(@"English");
    });
    
    it(@"should respect the preference order", ^{
        localizationTable = @{@"fr": @"Français",
                              @"de": @"Deutsch"};
        localizedObject = ZCRLocalize(localizationTable, specificity);
        
        expect(localizedObject.localizedObject).to.equal(@"Français");
    });
});

describe(@"using a supplied language", ^{
    NSString *languageCode = @"en-GB";
    
    context(@"with exact specificity", ^{
        beforeEach(^{
            specificity = ZCRLocalizationSpecificityExact;
        });
        
        it(@"should match the exact canonized language code", ^{
            localizationTable = @{@"en-Gb": @"British English",
                                  @"en": @"English",
                                  @"fr": @"Français"};
            
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            NSString *result = [localizedObject localizedObjectForLanguage:languageCode];
            
            expect(result).to.equal(@"British English");
        });
        
        it(@"should not match the generic language", ^{
            localizationTable = @{@"en": @"English",
                                  @"fr": @"Français"};
            
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            NSString *result = [localizedObject localizedObjectForLanguage:languageCode];
            
            expect(result).to.beNil();
        });
        
        it(@"should not match a language region", ^{
            localizationTable = @{@"en-Gb": @"British English",
                                  @"fr": @"Français"};
            
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            NSString *result = [localizedObject localizedObjectForLanguage:@"en"];
            
            expect(result).to.beNil();
        });
        
        it(@"should not match a different language", ^{
            localizationTable = @{@"fr": @"Français"};
            
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            NSString *result = [localizedObject localizedObjectForLanguage:@"en"];
            
            expect(result).to.beNil();
        });
    });
    
    context(@"with language specificity", ^{
        beforeEach(^{
            specificity = ZCRLocalizationSpecificityLanguage;
        });
        
        it(@"should return an exact match", ^{
            localizationTable = @{@"en-gb": @"British English",
                                  @"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            expect([localizedObject localizedObjectForLanguage:languageCode]).to.equal(@"British English");
        });
        
        it(@"should match the root language", ^{
            localizationTable = @{@"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            expect([localizedObject localizedObjectForLanguage:languageCode]).to.equal(@"English");
        });
        
        it(@"should use the user's preferred language order", ^{
            NSArray *preferredLanguages = @[@"fr",
                                            @"en-GB",
                                            @"en-AU",
                                            @"en"];
            OCMStub([localeClassMock preferredLanguages]).andReturn(preferredLanguages);
            
            localizationTable = @{@"en-au": @"Australian English",
                                  @"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            expect([localizedObject localizedObjectForLanguage:languageCode]).to.equal(@"Australian English");
        });
        
        it(@"should not match another language", ^{
            localizationTable = @{@"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            expect([localizedObject localizedObjectForLanguage:languageCode]).to.beNil();
        });
    });
    
    context(@"with most recent specificity", ^{
        beforeEach(^{
            specificity = ZCRLocalizationSpecificityMostRecent;
            
            NSArray *preferredLanguages = @[@"fr",
                                            @"en-GB",
                                            @"en-AU",
                                            @"en",
                                            @"de"];
            OCMStub([localeClassMock preferredLanguages]).andReturn(preferredLanguages);
        });
        
        it(@"should return an exact match", ^{
            localizationTable = @{@"en-GB": @"British English",
                                  @"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            expect([localizedObject localizedObjectForLanguage:languageCode]).to.equal(@"British English");
        });
        
        it(@"should return a root language match", ^{
            localizationTable = @{@"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            expect([localizedObject localizedObjectForLanguage:languageCode]).to.equal(@"English");
        });
        
        it(@"should respect the user's language preferences", ^{
            localizationTable = @{@"en-AU": @"Australian English",
                                  @"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            expect([localizedObject localizedObjectForLanguage:languageCode]).to.equal(@"Australian English");
        });
        
        it(@"should return the most recent matching language", ^{
            localizationTable = @{@"fr": @"Français",
                                  @"de": @"Deutsch"};
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            expect([localizedObject localizedObjectForLanguage:languageCode]).to.equal(@"Français");
        });
        
        it(@"should use the root most recent matching language", ^{
            localizationTable = @{@"en-GB": @"British English",
                                  @"en": @"English"};
            localizedObject = ZCRLocalize(localizationTable, specificity);
            
            expect([localizedObject localizedObjectForLanguage:@"fr"]).to.equal(@"British English");
        });
    });
});

describe(@"when the bundle includes more specific languages", ^{
    __block id bundleMock;
    
    beforeEach(^{
        specificity = ZCRLocalizationSpecificityMostRecent;
        
        bundleMock = OCMPartialMock([NSBundle mainBundle]);
        NSArray *bundleLanguages = @[@"Base",
                                     @"en-US",
                                     @"en",
                                     @"fr"];
        OCMStub([bundleMock localizations]).andReturn(bundleLanguages);
        
        NSArray *preferredLanguages = @[@"fr",
                                        @"en-GB",
                                        @"en",
                                        @"de"];
        OCMStub([localeClassMock preferredLanguages]).andReturn(preferredLanguages);
    });
    
    afterEach(^{
        [bundleMock stopMocking];
        bundleMock = nil;
    });
    
    it(@"should return an exact match", ^{
        localizationTable = @{@"en-US": @"American English",
                              @"en-GB": @"British English",
                              @"en": @"English"};
        localizedObject = ZCRLocalize(localizationTable, specificity);
        
        expect([localizedObject localizedObjectForLanguage:@"en-US"]).to.equal(@"American English");
    });
    
    it(@"should include the bundle languages in the preference order", ^{
        localizationTable = @{@"en-US": @"American English",
                              @"de": @"Deutsch"};
        localizedObject = ZCRLocalize(localizationTable, specificity);
        
        expect([localizedObject localizedObjectForLanguage:@"fr"]).to.equal(@"American English");
    });
});

SpecEnd
