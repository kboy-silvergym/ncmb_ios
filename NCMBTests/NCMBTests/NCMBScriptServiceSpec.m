/*
 Copyright 2016 NIFTY Corporation All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "Specta.h"
#import <Expecta/Expecta.h>
#import <NCMB/NCMB.h>
#import <OCMock/OCMock.h>


SpecBegin(NCMBScriptService)

describe(@"NCMBScriptService", ^{
    
    //Dummy API key from mobile backend document
    NSString *applicationKey = @"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56";
    NSString *clientKey = @"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75";
    beforeAll(^{
        [NCMB setApplicationKey:applicationKey
                      clientKey:clientKey];
    });
    
    beforeEach(^{

    });
    
    it (@"should set default endpoint", ^{
        NCMBScriptService *service = [[NCMBScriptService alloc]init];
        expect(service.endpoint).to.equal(@"https://logic.mb.api.cloud.nifty.com");
    });
    
    it (@"should return specified endpoint and request url",^{
        NCMBScriptService *service = [[NCMBScriptService alloc] initWithEndpoint:@"http://localhost"];
        expect(service.endpoint).to.equal(@"http://localhost");
    });
    
    it (@"should create request", ^{
        
        NCMBScriptService *service = [[NCMBScriptService alloc] init];
        
        [service executeScript:@"testScript.js"
                        method:NCMBSCRIPT_GET
                         param:nil
                    queryParam:@{@"where":@{@"testKey":@"testValue"}}
                     withBlock:nil];
        
        NSString *expectStr = [NSString stringWithFormat:@"%@/%@/%@/%@?%@",
                               defaultEndPoint,
                               apiVersion,
                               servicePath,
                               @"testScript.js",
                               @"where=%7B%22testKey%22%3A%22testValue%22%7D"];
        expect(service.request.URL.absoluteString).to.equal(expectStr);
        
    });
    
    it(@"should run callback response of execute asynchronously script in GET method", ^{
        waitUntil(^(DoneCallback done) {
            
            __block NSData *resultData = nil;
            
            NCMBScriptExecuteCallback callbackBlock = ^(NSData *result, NSError *error){
                if (error) {
                    failure(@"This shnould not happen");
                } else {
                    resultData = result;
                }
                NSString *expectStr = @"hello";
                expect([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]).to.equal(expectStr);
                
                done();
            };
            
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                                  delegate:nil
                                                             delegateQueue:[NSOperationQueue mainQueue]];
            
            id mockSession = OCMPartialMock(session);
            
            void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
                __unsafe_unretained void(^completionHandler)(NSData *data, NSURLResponse *res, NSError *error);
                [invocation getArgument:&completionHandler atIndex:3];
                
                
                NSURL *url = [NSURL URLWithString:@"http://sample.com"];
                NSDictionary *resDic = @{@"Content-Type":@"application/json"};
                
                NSHTTPURLResponse *res = [[NSHTTPURLResponse alloc] initWithURL:url
                                                                     statusCode:200
                                                                    HTTPVersion:@"HTTP/1.1"
                                                                   headerFields:resDic];
                
                //invoke completion handler of NSURLSession
                completionHandler([@"hello" dataUsingEncoding:NSUTF8StringEncoding], (NSURLResponse *)res, nil);
            };
            
            OCMStub([[mockSession dataTaskWithRequest:OCMOCK_ANY
                                   completionHandler:OCMOCK_ANY] resume]).andDo(invocation);
            
            NCMBScriptService *service = [[NCMBScriptService alloc] init];
            
            service.session = mockSession;
            [service executeScript:@"testScript.js"
                            method:NCMBSCRIPT_GET
                             param:nil
                        queryParam:nil
                         withBlock:callbackBlock];
        });
        
    });
    
    afterEach(^{

    });
    
    afterAll(^{

    });
});

SpecEnd