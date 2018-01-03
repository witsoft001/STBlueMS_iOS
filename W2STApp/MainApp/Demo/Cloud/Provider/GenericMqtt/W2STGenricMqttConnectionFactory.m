/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */
#import "ST_BlueMS-Swift.h"
#import "W2STGenricMqttConnectionFactory.h"
#import "W2STIBMWatsonIOTFeatureListener.h"
#import "W2STGenericMqttFeatureListener.h"
#import <MQTTFramework/MQTTFramework.h>

@implementation W2STGenricMqttConnectionFactory{
    NSString *mBrocker;
    NSString *mPort;
    NSString *mUser;
    NSString *mPassword;
    NSString *mClientId;
    BOOL mUseTls;
}

+(instancetype)createWithBorcker:(NSString*)brocker
                            port:(NSString*)port
                          useTls:(BOOL)secureConnection
                            user:(NSString*)user
                        password:(NSString*)password
                        clientId:(NSString*)clientId{
    return [[W2STGenricMqttConnectionFactory alloc] initWithBorcker:brocker
                                                               port:port
                                                            useTls:(BOOL)secureConnection
                                                               user:user
                                                           password:password
                                                           clientId:clientId];
}

-(instancetype)initWithBorcker:(NSString*)brocker
                          port:(NSString*)port
                        useTls:(BOOL)secureConnection
                          user:(NSString*)user
                      password:(NSString*)password
                      clientId:(NSString*)clientId{
    
    self = [super init];
    mBrocker = brocker;
    mPort = port;
    mUseTls = secureConnection;
    mUser = user;
    mPassword = password;
    mClientId = clientId;
    
    return self;
}


-(id<BlueMSCloudIotClient>) getSession{
    MCMQTTCFSocketTransport *transport = [[MCMQTTCFSocketTransport alloc] init];
    transport.host = mBrocker;
    transport.port = [mPort intValue];
    transport.tls=mUseTls;
    
    MCMQTTSession *session = [[MCMQTTSession alloc] init];
    session.transport = transport;
    if(mUser!=nil && mUser.length!=0)
        session.userName=mUser;
    if(mPassword!=nil && mPassword.length!=0)
        session.password=mPassword;
    
    session.clientId= mClientId;
    return [[BlueMSCloudIotMQTTClient alloc]init:session];
}


/**
 * we don't know where/how the deta are displayed we return null
 * @return nil since the page is not available
 */
-(NSURL*) getDataUrl{
    return nil;
}


/**
 * return a feature listern that will publish all the data to the remote brocker
 * the topic will be: clientId/FeatureName/FieldName
 * all the data are send encoded as a string
 *@param session connection to user to publish the data
 *@return feature listern taht will publish the data
 */
-(id<BlueSTSDKFeatureDelegate>)getFeatureDelegateWithSession:(id<BlueMSCloudIotClient>)session{
    BlueMSCloudIotMQTTClient *connection = (BlueMSCloudIotMQTTClient*)session;
    return [[W2STGenericMqttFeatureListener alloc]initWithSession:connection.connection clientId:mClientId];
}

-(BOOL)isSupportedFeature:(BlueSTSDKFeature*)feature{
    return true;
}

-(BOOL)enableCloudFwUpgradeForNode:(nonnull BlueSTSDKNode *)node
                        connection:(nonnull MCMQTTSession *)cloudConnection
                          callback:(nonnull OnFwUpgradeAvailableCallback)callback{
    return false;
}

@end
