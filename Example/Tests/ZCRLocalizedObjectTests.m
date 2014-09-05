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
        NSArray *preferredLanguages = @[@"en-GB",
                                        @"fr",
                                        @"en",
                                        @"de"];
        OCMStub([localeClassMock preferredLanguages]).andReturn(preferredLanguages);
    });
    
    it(@"uses the top preferred language", ^{
        localizationTable = @{@"en-GB": @"British English",
                              @"en": @"English",
                              @"fr": @"Français"};
        localizedObject = ZCRLocalize(localizationTable);
        
        expect(localizedObject).to.equal(@"British English");
    });
    
    it(@"uses the top language's root", ^{
        localizationTable = @{@"en": @"English",
                              @"fr": @"Français"};
        localizedObject = ZCRLocalize(localizationTable);
        
        expect(localizedObject).to.equal(@"English");
    });
    
    it(@"respects the preference order", ^{
        localizationTable = @{@"fr": @"Français",
                              @"de": @"Deutsch"};
        localizedObject = ZCRLocalize(localizationTable);
        
        expect(localizedObject).to.equal(@"Français");
    });
    
    it(@"allows unknown regions", ^{
        localizationTable = @{@"en-NARNIA": @"Narnian",
                              @"fr": @"Français"};
        localizedObject = ZCRLocalize(localizationTable);
        
        expect(localizedObject).to.equal(@"Narnian");
    });
});

describe(@"using a supplied language", ^{
    NSString *languageCode = @"en-GB";
    
    context(@"with exact specificity", ^{
        beforeEach(^{
            specificity = ZCRLocalizationSpecificityExact;
        });
        
        it(@"matchs the exact canonized language code", ^{
            localizationTable = @{@"en-Gb": @"British English",
                                  @"en": @"English",
                                  @"fr": @"Français"};
            
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(languageCode);
            
            expect(localizedObject).to.equal(@"British English");
        });
        
        it(@"does not match the generic language", ^{
            localizationTable = @{@"en": @"English",
                                  @"fr": @"Français"};
            
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(languageCode);
            
            expect(localizedObject.localizedObject).to.beNil();
        });
        
        it(@"does not match a language region", ^{
            localizationTable = @{@"en-Gb": @"British English",
                                  @"fr": @"Français"};
            
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(@"en");
            
            expect(localizedObject.localizedObject).to.beNil();
        });
        
        it(@"does not match a different language", ^{
            localizationTable = @{@"fr": @"Français"};
            
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(@"en");
            
            expect(localizedObject.localizedObject).to.beNil();
        });
    });
    
    context(@"with language specificity", ^{
        beforeEach(^{
            specificity = ZCRLocalizationSpecificityLanguage;
        });
        
        it(@"returns an exact match", ^{
            localizationTable = @{@"en-gb": @"British English",
                                  @"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(languageCode);
            
            expect(localizedObject).to.equal(@"British English");
        });
        
        it(@"matches the root language", ^{
            localizationTable = @{@"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(languageCode);
            
            expect(localizedObject).to.equal(@"English");
        });
        
        it(@"uses the user's preferred language order", ^{
            NSArray *preferredLanguages = @[@"fr",
                                            @"en-GB",
                                            @"en-AU",
                                            @"en"];
            OCMStub([localeClassMock preferredLanguages]).andReturn(preferredLanguages);
            
            localizationTable = @{@"en-au": @"Australian English",
                                  @"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(languageCode);
            
            expect(localizedObject).to.equal(@"Australian English");
        });
        
        it(@"does not match another language", ^{
            localizationTable = @{@"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(languageCode);
            
            expect(localizedObject.localizedObject).to.beNil();
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
        
        it(@"returns an exact match", ^{
            localizationTable = @{@"en-GB": @"British English",
                                  @"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(languageCode);
            
            expect(localizedObject).to.equal(@"British English");
        });
        
        it(@"returns a root language match", ^{
            localizationTable = @{@"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(languageCode);
            
            expect(localizedObject).to.equal(@"English");
        });
        
        it(@"respects the user's language preferences", ^{
            localizationTable = @{@"en-AU": @"Australian English",
                                  @"en": @"English",
                                  @"fr": @"Français"};
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(languageCode);
            
            expect(localizedObject).to.equal(@"Australian English");
        });
        
        it(@"returns the most recent matching language", ^{
            localizationTable = @{@"fr": @"Français",
                                  @"de": @"Deutsch"};
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(languageCode);
            
            expect(localizedObject).to.equal(@"Français");
        });
        
        it(@"uses the root most recent matching language", ^{
            localizationTable = @{@"en-GB": @"British English",
                                  @"en": @"English"};
            localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(@"fr");
            
            expect(localizedObject).to.equal(@"British English");
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
    
    it(@"returns an exact match", ^{
        localizationTable = @{@"en-US": @"American English",
                              @"en-GB": @"British English",
                              @"en": @"English"};
        localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(@"en-US");
        
        expect(localizedObject).to.equal(@"American English");
    });
    
    it(@"should include the bundle languages in the preference order", ^{
        localizationTable = @{@"en-US": @"American English",
                              @"de": @"Deutsch"};
        localizedObject = ZCRLocalize(localizationTable).withSpecificity(specificity).inLanguage(@"fr");
        
        expect(localizedObject).to.equal(@"American English");
    });
});

describe(@"with a default object", ^{
    beforeEach(^{
        localizationTable = @{@"en": @"English",
                              @"fr": @"Français"};
    });
    
    it(@"uses the object when no localization exists", ^{
        localizedObject = ZCRLocalize(localizationTable).withSpecificity(ZCRLocalizationSpecificityLanguage).withDefault(@"Unknown").inLanguage(@"de");
        
        expect(localizedObject).to.equal(@"Unknown");
    });
    
    it(@"ignores the object when another localization is found", ^{
        localizedObject = ZCRLocalize(localizationTable).withSpecificity(ZCRLocalizationSpecificityLanguage).withDefault(@"Unknown").inLanguage(@"fr");

        expect(localizedObject).to.equal(@"Français");
    });
});


describe(@"as a proxy", ^{
    beforeEach(^{
        localizationTable = @{@"en": @"English",
                              @"fr": @"Français"};
    });
    
    it(@"vends the desired method when a localization exists", ^{
        id object  = ZCRLocalize(localizationTable).withSpecificity(ZCRLocalizationSpecificityLanguage).inLanguage(@"en");
        
        expect([object lowercaseString]).to.equal(@"english");
    });
});

SpecEnd
