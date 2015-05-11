//
//  CMRAppDelegate.m
//  Proxyfier
//
//  Created by Luis von der Eltz on 04.09.13.
//  Copyright (c) 2013 Luis von der Eltz. All rights reserved.
//

#import "CMRAppDelegate.h"
#import "NSDate+TimeAgo.h"


@implementation CMRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    PM = [[EPProxyModifiy alloc] init];
    PLF = [[ProxyListFetcher alloc] init];

    NSLog(@"%@",@"Start App. ()");
    
    [self.ProxyList setDoubleAction:@selector(ToggleProxy:)];
    self.ProxyList.dataSource = PLF;
    self.ProxyList.delegate =self;
    
    [self RefreshProxies];
    
    self.window.delegate = self;
}



- (IBAction)ToggleProxy:(id)sender {
    
    Proxy*p = [PLF.Proxies objectAtIndex:self.ProxyList.selectedRow];
    if (p==nil)
        return;
    
    if (proxyEnabled) {
        if ([PM changeProxySettingsWithAddress:p.host Port:p.port isON:NO]) {
            proxyEnabled = NO;
            
            [self.ActivateButton setTitle:@"Activate"];
            [self.window setTitle:@"localhost"];
            
            currentProxy = p;
        }
    
    }else{
        if ([PM changeProxySettingsWithAddress:p.host Port:p.port isON:YES]) {
            proxyEnabled = YES;
            [self.ActivateButton setTitle:@"Deactivate"];
            [self.window setTitle:[NSString stringWithFormat:@"%@:%@",p.host,p.port]];

            currentProxy = nil;
        }
    }
 
}


#pragma mark - Refresh
- (void)RefreshProxies {

    [PLF Fetch];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                         initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
    NSDate* update = [formatter dateFromString:PLF.lastUpdated];
    
    self.updateLabel.stringValue = [update timeAgo];

    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.ProxyList selectRowIndexes:indexSet byExtendingSelection:NO];
    [self.ProxyList reloadData];
    
}

#pragma mark - @NSWindowDelegate
-(void)windowWillClose:(NSNotification *)notification {
    if (currentProxy)
        [PM changeProxySettingsWithAddress:currentProxy.host Port:currentProxy.port isON:NO];

}


@end
