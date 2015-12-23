//
//  XMOpenAL.m
//  XMOpenAL
//
//  Created by mifit on 15/12/8.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import "XMOpenAL.h"
#import <OpenAL/OpenAL.h>

#import <AudioToolbox/AudioFile.h>
@interface XMOpenAL(){
    ALCcontext         *m_Context;           //内容，相当于给音频播放器提供一个环境描述
    ALCdevice          *m_Device;             //硬件，获取电脑或者ios设备上的硬件，提供支持
    ALuint             m_sourceID;           //音源，相当于一个ID,用来标识音源
    NSCondition        *m_DecodeLock;       //线程锁
}
@end

@implementation XMOpenAL

- (BOOL)initOpenAl {
    if (m_Device ==nil) {
        m_Device = alcOpenDevice(NULL);  //参数为NULL , 让ALC 使用默认设备
    }
    
    if (m_Device==nil) {
        return NO;
    }
    
    if (m_Context==nil) {
        if (m_Device) {
            m_Context =alcCreateContext(m_Device, NULL); //与初始化device是同样的道理
            alcMakeContextCurrent(m_Context);
        }
    }
    
    m_DecodeLock =[[NSCondition alloc] init];
    if (m_Context==nil) {
        return NO;
    }
    
    /*这里有我注释掉的监测方法，alGetError()用来监测环境搭建过程中是否有错误
     在这里，可以说是是否出错都可以，为什么这样说呢？ 因为运行到这里之前，
     如果加上了alSourcef(m_sourceID, AL_SOURCE_TYPE, AL_STREAMING);
     这个方法，这里就会监测到错误，注释掉这个方法就不会有错误。（具体为什么，我
     也不知道～～～，知道的大神麻烦说下～～～），加上这个方法，在这里监测出错误
     对之后播放声音无影响，所以，这里可以注释掉下面的alGetError()。
     */
    //    ALenum  error;
    //    if ((error=alGetError())!=AL_NO_ERROR)
    //    {
    //        return NO;
    //    } 
    return YES; 
}

- (AudioFileID)openAudioFile:(NSString*)filePath {
    AudioFileID outAFID;
    // use the NSURl instead of a cfurlref cuz it is easier
    NSURL * afUrl = [NSURL fileURLWithPath:filePath];
    OSStatus result = AudioFileOpenURL((__bridge CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
    if (result != 0) NSLog(@"cannot openf file: %@",filePath);
    return outAFID;
}

- (UInt32)audioFileSize:(AudioFileID)fileDescriptor {
    UInt64 outDataSize = 0;
    UInt32 thePropSize = sizeof(UInt64);
    OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
    if(result != 0) NSLog(@"cannot find file size");
    return (UInt32)outDataSize;
}

//清除已存在的buffer，这个函数其实没什么的，就只是用来清空缓存而已，我只是多一步将播放声音放到这个函数里。
- (BOOL)updataQueueBuffer {
    ALint  state;
    int processed ,queued;
    
    alGetSourcei(m_sourceID, AL_SOURCE_STATE, &state);
    if (state !=AL_PLAYING) {
        [self playSound];
        return NO;
    }
    
    alGetSourcei(m_sourceID, AL_BUFFERS_PROCESSED, &processed);
    alGetSourcei(m_sourceID, AL_BUFFERS_QUEUED, &queued);
    
    
    NSLog(@"Processed = %d\n", processed);
    NSLog(@"Queued = %d\n", queued);
    while (processed--) {
        ALuint  buffer;
        alSourceUnqueueBuffers(m_sourceID, 1, &buffer);
        alDeleteBuffers(1, &buffer);
    }
    return YES;

}

//这个函数就是比较重要的函数了， 将收到的pcm数据放到缓存器中，再拿出来播放
- (void)openAudio:(unsigned char*)pBuffer length:(UInt32)pLength {
    
    [m_DecodeLock lock];
    
    ALenum  error =AL_NO_ERROR;
    if ((error =alGetError())!=AL_NO_ERROR) {
        [m_DecodeLock unlock];
        return ;
    }
    if (pBuffer ==NULL) {
        return ;
    }
    alGenSources(1, &m_sourceID);
    
    if ((error =alGetError())!=AL_NO_ERROR) {
        [m_DecodeLock unlock];
        return ;
    }
    
    ALuint    bufferID =0; //存储声音数据，建立一个pcm数据存储器，初始化一块区域用来保存声音数据
    alGenBuffers(1, &bufferID);
    
    if ((error = alGetError())!=AL_NO_ERROR) {
        NSLog(@"Create buffer failed");
        [m_DecodeLock unlock];
        return;
    }
    
    ///最重要的是要与你的音频匹配
    alBufferData(bufferID, AL_FORMAT_STEREO16, pBuffer , pLength, 44100 ); 
    
    if ((error =alGetError())!=AL_NO_ERROR) {
        NSLog(@"create bufferData failed");
        [m_DecodeLock unlock];
        return;
    }
    
    //添加到缓冲区
    alSourceQueueBuffers(m_sourceID, 1, &bufferID);
    
    if ((error =alGetError())!=AL_NO_ERROR) {
        NSLog(@"add buffer to queue failed");
        [m_DecodeLock unlock];
        return;
    }
    
    if ((error=alGetError())!=AL_NO_ERROR) {
        NSLog(@"play failed");
        alDeleteBuffers(1, &bufferID);
        [m_DecodeLock unlock];
        return;
    }
    alSourcei(m_sourceID, AL_LOOPING, AL_TRUE);
    [m_DecodeLock unlock];
    
}

- (void)updateQue{
    [self updataQueueBuffer];
}
- (void)playSound {
    ALint  state;
    alGetSourcei(m_sourceID, AL_SOURCE_STATE, &state);
    if (state != AL_PLAYING) {
        alSourcePlay(m_sourceID);
    }
}

- (void)stopSound {
    ALint  state;
    alGetSourcei(m_sourceID, AL_SOURCE_STATE, &state);
    if (state != AL_STOPPED) {
        alSourceStop(m_sourceID);
    }
}

- (void)clearOpenAL {
    alDeleteSources(1, &m_sourceID);
    if (m_Context != nil) {
        alcDestroyContext(m_Context);
        m_Context=nil;
    }
    
    if (m_Device !=nil) {
        alcCloseDevice(m_Device);
        m_Device=nil;
    }
}

@end
