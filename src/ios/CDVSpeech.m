/********* CDVSpeech.m Cordova Plugin Implementation *******/

#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechConstant.h"

#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
#import "iflyMSC/IFlySpeechRecognizer.h"

#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"

#import "CDVSpeech.h"

#define STR_EVENT @"event"
#define STR_CODE @"code"
#define STR_MESSAGE @"message"
#define STR_VOLUME @"volume"
#define STR_RESULTS @"results"
#define STR_PROGRESS @"progress"

// always replace the appid and the SDK with what you get from voicecloud.cn
#define SPEECH_APP_ID @"53cbac8d"

@interface CDVSpeech()
- (void) fireEvent:(NSString*)event;
@end

@implementation CDVSpeech

- (void)login:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    
    self.appId = SPEECH_APP_ID;
    //self.appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SPEECH_APP_ID"];
    
//    [self.commandDelegate runInBackground:^{
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",self.appId];
    [IFlySpeechUtility createUtility:initString];
//    }];
}

- (void)startListening:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: startListening"); 
    NSDictionary* options = [command.arguments objectAtIndex:0 withDefault:[NSNull null]];
//    [self.commandDelegate runInBackground:^{
        if (!self.recognizer){
            self.recognizer = [IFlySpeechRecognizer sharedInstance];
            self.recognizer.delegate = self;
            [self.recognizer setParameter:@"iat" forKey:@"domain"];
            [self.recognizer setParameter:@"16000" forKey:@"sample_rate"];
            [self.recognizer setParameter:@"0" forKey:@"plain_result"];
            [self.recognizer setParameter:@"asr.pcm" forKey:@"asr_audio_path"];
            
            NSLog(@"Speech :: createRecognizer");
        }
        if ((NSNull *)options != [NSNull null]) {
            NSArray *keys = [options allKeys];
            for (NSString *key in keys) {
                NSString *value = [options objectForKey:key];
                [self.recognizer setParameter:value forKey:key];
            }
        }
        [self.recognizer startListening];
//    }];
}

- (void)stopListening:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: stopListening");
//    [self.commandDelegate runInBackground:^{
        [self.recognizer stopListening];
//    }];
}

- (void)cancelListening:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: cancelListening");    
//    [self.commandDelegate runInBackground:^{
        [self.recognizer cancel];
//    }];
}

- (void)startSpeaking:(CDVInvokedUrlCommand*)command
{
    NSString* text = [command.arguments objectAtIndex:0];
    NSDictionary* options = [command.arguments objectAtIndex:1 withDefault:[NSNull null]];
    NSLog(@"Speech :: startSpeaking - %@", text);  
 //   [self.commandDelegate runInBackground:^{
        if (!self.synthesizer){
            self.synthesizer = [IFlySpeechSynthesizer sharedInstance];
            self.synthesizer.delegate = self;
            
            [self.synthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];//合成的语速,取值范围 0~100
            [self.synthesizer setParameter:@"80" forKey:[IFlySpeechConstant VOLUME]];//合成的音量;取值范围 0~100
            [self.synthesizer setParameter:@"vixr" forKey:[IFlySpeechConstant VOICE_NAME]];//发音人,默认为”xiaoyan”
            
            [self.synthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];//音频采样率,目前支持的采样率有 16000 和 8000;
            [self.synthesizer setParameter:@"tts.pcm" forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
            
            NSLog(@"Speech :: createSynthesizer");
        }
        if ((NSNull *)options != [NSNull null]) {
            NSArray *keys = [options allKeys];
            for (NSString *key in keys) {
                NSString *value = [options objectForKey:key];
                [self.synthesizer setParameter:value forKey:key];
            }
        }        
        [self.synthesizer startSpeaking:text];
 //   }];
}

- (void)pauseSpeaking:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: pauseSpeaking"); 
//    [self.commandDelegate runInBackground:^{
        [self.synthesizer pauseSpeaking];
//    }];
}

- (void)resumeSpeaking:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: resumeSpeaking"); 
//    [self.commandDelegate runInBackground:^{
        [self.synthesizer resumeSpeaking];
//    }];
}

- (void)stopSpeaking:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: stopSpeaking"); 
//    [self.commandDelegate runInBackground:^{
        [self.synthesizer stopSpeaking];
//    }];
}

#pragma mark -
#pragma mark IFlySpeechRecognizerDelegate
- (void) onError:(IFlySpeechError *) errorCode
{
    NSLog(@"Speech :: onError - %d", errorCode.errorCode); 
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"SpeechError",STR_EVENT,[NSNumber numberWithInt:errorCode.errorCode],STR_CODE,errorCode.errorDesc,STR_MESSAGE, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) onResults:(NSArray *) results isLast:(BOOL) isLast
{
    NSLog(@"Speech :: onResults - %@", results); 
    if (self.callbackId) {
         NSMutableString *text = [[NSMutableString alloc] init];
        NSDictionary *dic = [results objectAtIndex:0];
        for (NSString *key in dic) {
            [text appendFormat:@"%@",key];
        }
        NSLog(@"Recognize Result: %@, %d",text, isLast?1:0);
        
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"SpeechResults",STR_EVENT,text,STR_RESULTS, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) onVolumeChanged:(int)volume
{
    NSLog(@"Speech :: onVolumeChanged - %d", volume); 
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"VolumeChanged",STR_EVENT,[NSNumber numberWithInt:volume],STR_VOLUME, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) onBeginOfSpeech
{
    NSLog(@"Speech :: onBeginOfSpeech");     
    [self fireEvent:@"SpeechBegin"];
}

- (void) onEndOfSpeech
{
    NSLog(@"Speech :: onEndOfSpeech");   
    [self fireEvent:@"SpeechEnd"];
}

- (void) onCancel
{
    NSLog(@"Speech :: onCancel");     
    [self fireEvent:@"SpeechCancel"];
}

#pragma mark -
#pragma mark IFlySpeechSynthesizerDelegate
- (void) onCompleted:(IFlySpeechError*)error
{
    NSLog(@"Speech :: onCompleted - %d", error.errorCode);     
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"SpeakCompleted",STR_EVENT,[NSNumber numberWithInt:error.errorCode],STR_CODE,error.errorDesc,STR_MESSAGE, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) onSpeakBegin
{
    NSLog(@"Speech :: onSpeakBegin");      
    [self fireEvent:@"SpeakBegin"];
}

- (void) onBufferProgress:(int)progress message:(NSString *)msg
{
    NSLog(@"Speech :: onBufferProgress - %d", progress);     
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"BufferProgress",STR_EVENT,[NSNumber numberWithInt:progress],STR_PROGRESS,msg,STR_MESSAGE, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) onSpeakProgress:(int)progress
{
    NSLog(@"Speech :: onSpeakProgress - %d", progress);     
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"SpeakProgress",STR_EVENT,[NSNumber numberWithInt:progress],STR_PROGRESS, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) onSpeakPaused
{
    NSLog(@"Speech :: onSpeakPaused");      
    [self fireEvent:@"SpeakPaused"];
}

- (void) onSpeakResumed
{
    NSLog(@"Speech :: onSpeakResumed");      
    [self fireEvent:@"SpeakResumed"];
}

- (void) onSpeakCancel
{
    NSLog(@"Speech :: onSpeakCancel");      
    [self fireEvent:@"SpeakCancel"];
}

- (void) fireEvent:(NSString*)event
{
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObject:event forKey:STR_EVENT];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

@end
