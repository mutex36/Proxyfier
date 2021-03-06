//
//  ProxyListCurler.m
//  Proxyfier
//
//  Created by Luis von der Eltz on 04.09.13.
//  Copyright (c) 2013 Luis von der Eltz. All rights reserved.
//

#import "ProxyListFetcher.h"
#import "XMLDictionary.h"

NSString *rss = @"http://www.xroxy.com/proxyrss.xml";

@implementation ProxyListFetcher

@synthesize Proxies;

-(void)Fetch {
    
    NSURL *feedURL = [NSURL URLWithString:rss];
    NSString *raw = [[NSString alloc] initWithContentsOfURL:feedURL
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
 
    NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLString:raw];
    
    self.lastUpdated = [xmlDoc stringValueForKeyPath:@"channel.lastBuildDate"];

    NSArray* proxyLists = [xmlDoc arrayValueForKeyPath:@"channel.item.prx:proxy"];
    NSMutableArray * bind = [NSMutableArray array];
    
    [proxyLists enumerateObjectsUsingBlock:^(NSArray* currentList,NSUInteger index,BOOL* stop) {
        
        if (![currentList isKindOfClass:[NSNull class]]) {
            for (NSDictionary* element in currentList) {
                if ([element isKindOfClass:[NSDictionary class]]) {
                    Proxy*proxy = [Proxy new];
                    proxy.host = [element valueForKey:@"prx:ip"];
                    proxy.port = [element valueForKey:@"prx:port"];
                    proxy.type = [element valueForKey:@"prx:type"];
                    proxy.reliability = [[element valueForKey:@"prx:reliability"] integerValue];
                    proxy.country = [element valueForKey:@"prx:country_code"];
                    
                    [bind addObject:proxy];
                }
            }
        }
        
    }];
    
    self.Proxies = bind;
    
}


#pragma mark - @UITableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.Proxies.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    Proxy *correspondingProxy = self.Proxies[row];
    return [correspondingProxy 
        valueForKey: [tableColumn identifier]];
    
}



@end
