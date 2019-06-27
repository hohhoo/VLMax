//
//  iMDVLNClientProtocol.h
//  iMobileDevice
//
//  Created by Daniel Love on 21/07/2014.
//  Copyright (c) 2014 Daniel Love. All rights reserved.
//

@protocol iMDVLNClientProtocol <NSObject>

- (BOOL) isConnected;
- (BOOL) connectToClient:(NSError **)error;
- (BOOL) disconnectFromClient:(NSError **)error;

@end
