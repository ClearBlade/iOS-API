//
//  CBQueryTests.m
//  testApp
//
//  Created by Tyler Dodge on 11/11/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import "TestCBItem.h"
#import "CBAPI.h"

@interface CBQueryTests : AsyncTestCase
@property (strong, nonatomic) CBQuery * defaultQuery;

@end

@implementation CBQueryTests

- (void)setUp {
    [super setUp];
    [ClearBlade initSettingsWithAppKey:APP_KEY withAppSecret:APP_SECRET withServerAddress:PLATFORM_ADDRESS];
    self.defaultQuery = [CBQuery queryWithCollectionID:TEST_COLLECTION];
}

- (void)tearDown {
    [super tearDown];
}

-(void)testQueryDescription {
    CBQuery * query = [CBQuery queryWithCollectionID:TEST_COLLECTION];
    NSString * expectedFormat = [NSString stringWithFormat:@"Query: Collection ID <%@>, Where Clause <>", TEST_COLLECTION];
    XCTAssertTrue([[query description] isEqualToString:expectedFormat], @"Empty query should have this format");
    expectedFormat = [NSString stringWithFormat:@"Query: Collection ID <%@>, Where Clause <key1 = 'value1'>", TEST_COLLECTION];
    [query equalTo:@"value1" for:@"key1"];
    XCTAssertTrue([[query description] isEqualToString:expectedFormat], @"Single argument query should have this format");
    
    expectedFormat = [NSString stringWithFormat:@"Query: Collection ID <%@>, Where Clause <key1 = 'value1' AND key2 = 'value2'>", TEST_COLLECTION];
    [query equalTo:@"value2" for:@"key2"];
    XCTAssertTrue([[query description] isEqualToString:expectedFormat], @"Two argument query should have this format");
    [query startNextOrClause];
    XCTAssertTrue([[query description] isEqualToString:expectedFormat], @"Empty or clause should be ignored");
    [query equalTo:@"value3" for:@"key3"];
    expectedFormat = [NSString stringWithFormat:@"Query: Collection ID <%@>, Where Clause <key1 = 'value1' AND key2 = 'value2' OR key3 = 'value3'>", TEST_COLLECTION];
    XCTAssertTrue([[query description] isEqualToString:expectedFormat], @"Query with or clause should have this format");
}

- (void)testMultipleReturnedFetch {
    TestCBItem * item1 = [TestCBItem itemWithStringColumn:@"TEST" withIntColumn:5];
    TestCBItem * item2 = [TestCBItem itemWithStringColumn:@"TEST" withIntColumn:6];
    item1.collectionID = TEST_COLLECTION;
    item2.collectionID = TEST_COLLECTION;
    [[[CBQuery queryWithCollectionID:item1.collectionID] equalTo:@"TEST" for:item1.stringColumnName] removeWithSuccessCallback:^(NSArray * items) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError *error, id JSON) {
        XCTFail(@"Unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [[CBQuery queryWithCollectionID:item1.collectionID] insertItem:item1 withSuccessCallback:^(NSMutableArray *successItems) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [[CBQuery queryWithCollectionID:item1.collectionID] insertItem:item1 withSuccessCallback:^(NSMutableArray *successItems) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [[[CBQuery queryWithCollectionID:item1.collectionID] equalTo:@"TEST" for:item1.stringColumnName] fetchWithSuccessCallback:^(NSMutableArray * items) {
        bool isItem1InArray = false;
        bool isItem2InArray = false;
        for (CBItem * item in items) {
            TestCBItem * testItem = [TestCBItem itemFromCBItem:item];
            if ([testItem isEqualToCBItem:item1]) {
                isItem1InArray = true;
            } else if ([testItem isEqualToCBItem:item2]) {
                isItem2InArray = true;
            }
        }
        XCTAssertTrue(isItem1InArray, @"%@ should be in fetch return: %@", item1, items);
        XCTAssertTrue(isItem2InArray, @"%@ should be in fetch return: %@", item2, items);
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError *error, id JSON) {
        XCTFail(@"Unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [[[CBQuery queryWithCollectionID:item1.collectionID] equalTo:@"TEST" for:item1.stringColumnName] removeWithSuccessCallback:^(NSArray * items) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError *error, id JSON) {
        XCTFail(@"Unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

- (void)testSingleArgumentFetch {
    TestCBItem * item = [TestCBItem itemWithStringColumn:@"TEST"
                                           withIntColumn:5];
    item.collectionID = TEST_COLLECTION;
    [[[CBQuery queryWithCollectionID:item.collectionID] equalTo:@"TEST" for:item.stringColumnName] removeWithSuccessCallback:^(NSArray * items) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [item saveWithSuccessCallback:^(CBItem *item) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(CBItem *item, NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [self.defaultQuery equalTo:@"TEST" for:STRING_COLUMN];
    
    [self.defaultQuery fetchWithSuccessCallback:^(NSMutableArray * array) {
        XCTAssertTrue([array count] == 1, @"Should be single response to equal to Test One");
        CBItem * otherItem = [TestCBItem itemFromCBItem:[array objectAtIndex:0]];
        XCTAssertTrue([item isEqualToCBItem:otherItem], @"Should be item inserted");
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [self.defaultQuery removeWithSuccessCallback:^(NSMutableArray * array) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

@end
