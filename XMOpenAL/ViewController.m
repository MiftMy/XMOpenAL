//
//  ViewController.m
//  XMOpenAL
//
//  Created by mifit on 15/12/8.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import "ViewController.h"
#import <OpenAL/OpenAL.h>
#import <AVFoundation/AVFoundation.h>
#import "XMOpenAL.h"
@interface ViewController (){
    ALCcontext *Context;
    ALCdevice *Device;
    unsigned int sourceID;
    
    XMOpenAL *player;
}
- (IBAction)play:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//// 初始化设备
//    Device = alcOpenDevice(NULL);
//    if (Device == nil)NSLog(@"ccc");
//    //Create context(s)
//    Context=alcCreateContext(Device, NULL);
//    //Set active context
//    alcMakeContextCurrent(Context);
//    // Clear Error Code  
//    alGetError();
//    
//    NSString *sPath = [[NSBundle mainBundle]pathForResource:@"a" ofType:@"wav"];
//    
//    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *doc = [arr objectAtIndex:0];
//    NSString *path = [doc stringByAppendingPathComponent:@"outputm.caf"];
//    
//    AudioFileID outAFID;
//    // use the NSURl instead of a cfurlref cuz it is easier
//    NSURL * afUrl = [NSURL fileURLWithPath:path];
//    OSStatus result = AudioFileOpenURL((__bridge CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
//    if (result != 0) NSLog(@"cannot openf file: %@",sPath);
//    
//    UInt32 outDataSize = 0;
//    UInt32 thePropSize = sizeof(UInt64);
//    result = AudioFileGetProperty(outAFID, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
//    if(result != 0) NSLog(@"cannot find file size");
//    
//    // this is where the audio data will live for the moment
//    unsigned char * outData = malloc(outDataSize);
//    
//    // this where we actually get the bytes from the file and put them
//    // into the data buffer
//    result = noErr;
//    result = AudioFileReadBytes(outAFID, false, 0, &outDataSize, outData);
//    AudioFileClose(outAFID); //close the file
//    
//    if (result != 0) NSLog(@"cannot load effect");
//    
//    unsigned int bufferID;
//    // grab a buffer ID from openAL
//    alGenBuffers(1, &bufferID);
//    
//    alBufferData(bufferID, AL_FORMAT_STEREO16, outData, outDataSize, 44100);
//    
//    // grab a source ID from openAL
//    alGenSources(1, &sourceID);
//    // set loop sound
//    alSourcei(sourceID, AL_LOOPING, AL_TRUE);
//    alSpeedOfSound(1.0);
//    alDopplerFactor(1.0);
//    alDopplerVelocity(1.0);
//    alSourcef(sourceID, AL_PITCH, 1.0);
//    alSourcef(sourceID, AL_GAIN, 1.0);
//    alSourcef(sourceID, AL_SOURCE_TYPE, AL_STREAMING);
//    // attach the buffer to the source
//    alSourcei(sourceID, AL_BUFFER, bufferID);
//    
//    if (outData)
//    {
//        free(outData);
//        outData = NULL;
//    }
//    
//    alSourcePlay(sourceID);
    
//// 设置Source属性：
//    //set source position
//    //alSource3f(alSource,AL_POSITION, xposition, yposition, zposition);
//    alSource3f(sourceID,AL_POSITION, 0, 0, 0);
//    
//    //set source velocity
//    //alSource3f(alSource,AL_VELOCITY, xvelocity, yvelocity, zvelocity);
//    alSource3f(sourceID,AL_VELOCITY, 0, 0, 0);
    
//// 听者：
//    float listenerx, listenery, listenerz;
//    float vec[6];
//    
//    listenerx=10.0f;
//    listenery=0.0f;
//    listenerz=5.0f;
//    
//    vec[0] = 0; //forward vector x value
//    vec[1] = 0; //forward vector y value
//    vec[2] = 0; //forward vector z value
//    vec[3] = 1; //up vector x value
//    vec[4] = 1; //up vector y value
//    vec[5] = 1; //up vector z value
//    //set current listener position
//    //alListener3f(AL_POSITION, listenerx, listenery, listenerz);
//    alListener3f(AL_POSITION, 0, 0, 0);
//    
//    //set current listener orientation
//    alListenerfv(AL_ORIENTATION, vec);
    
    
    //[NSTimer scheduledTimerWithTimeInterval:1/1000.0 target:self selector:@selector(updateBuffer) userInfo:nil repeats:YES];
    // To stop the sound
    //alSourceStop(alSource);
    
    
    
//// 清除工作
//    //delete our source
//    alDeleteSources(1,&alSource);
//    //delete our buffer
//    alDeleteBuffers(1,&alSampleSet);
//    //Get active context
//    Context=alcGetCurrentContext();
//    //Get device for active context
//    Device=alcGetContextsDevice(Context);
//    //Disable context
//    alcMakeContextCurrent(NULL);
//    //Release context(s)
//    alcDestroyContext(Context);
//    //Close device  
//    alcCloseDevice(Device);

    
    
///打开你的命令行终端输入：
///    usr/bin/afconvert -f caff -d LEI16@44100 xxxx.mp3 outputm.caf
///你可能会问这到底是在干什么？这是将文件转换为Little-Endian（低地址低字节） 16位，采样率44，100的格式。通常存储为.caf。
///
///----------------------------------------------------------------------------------------
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doc = [arr objectAtIndex:0];
    NSString *path = [doc stringByAppendingPathComponent:@"outputm.caf"];
    
    player = [[XMOpenAL alloc]init];
    [player initOpenAl];
    AudioFileID outID;
    // use the NSURl instead of a cfurlref cuz it is easier
    NSURL * alUrl = [NSURL fileURLWithPath:path];
    OSStatus result = AudioFileOpenURL((__bridge CFURLRef)alUrl, kAudioFileReadPermission, 0, &outID);
    if (result != 0) NSLog(@"cannot openf file: %@",path);
    
    UInt32 odSize = 0;
    UInt32 pSize = sizeof(UInt64);
    result = AudioFileGetProperty(outID, kAudioFilePropertyAudioDataByteCount, &pSize, &odSize);
    if(result != 0) NSLog(@"cannot find file size");
    
    // this is where the audio data will live for the moment
    unsigned char * outDatas = malloc(odSize);
    
    // this where we actually get the bytes from the file and put them
    // into the data buffer
    result = noErr;
    result = AudioFileReadBytes(outID, false, 0, &odSize, outDatas);
    
    [player openAudio:outDatas length:odSize];
    [player playSound];
//--------------------------------------------------------------------------------------------
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender {
    
}
@end
