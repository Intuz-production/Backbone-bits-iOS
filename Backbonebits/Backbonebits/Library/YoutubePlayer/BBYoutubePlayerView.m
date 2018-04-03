// Copyright 2014 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "BBYoutubePlayerView.h"

// These are instances of NSString because we get them from parsing a URL. It would be silly to
// convert these into an integer just to have to convert the URL query string value into an integer
// as well for the sake of doing a value comparison. A full list of response error codes can be
// found here:
//      https://developers.google.com/youtube/iframe_api_reference
NSString static *const kBBYoutubePlayerStateUnstartedCode = @"-1";
NSString static *const kBBYoutubePlayerStateEndedCode = @"0";
NSString static *const kBBYoutubePlayerStatePlayingCode = @"1";
NSString static *const kBBYoutubePlayerStatePausedCode = @"2";
NSString static *const kBBYoutubePlayerStateBufferingCode = @"3";
NSString static *const kBBYoutubePlayerStateCuedCode = @"5";
NSString static *const kBBYoutubePlayerStateUnknownCode = @"unknown";

// Constants representing playback quality.
NSString static *const kBBYoutubePlaybackQualitySmallQuality = @"small";
NSString static *const kBBYoutubePlaybackQualityMediumQuality = @"medium";
NSString static *const kBBYoutubePlaybackQualityLargeQuality = @"large";
NSString static *const kBBYoutubePlaybackQualityHD720Quality = @"hd720";
NSString static *const kBBYoutubePlaybackQualityHD1080Quality = @"hd1080";
NSString static *const kBBYoutubePlaybackQualityHighResQuality = @"highres";
NSString static *const kBBYoutubePlaybackQualityAutoQuality = @"auto";
NSString static *const kBBYoutubePlaybackQualityDefaultQuality = @"default";
NSString static *const kBBYoutubePlaybackQualityUnknownQuality = @"unknown";

// Constants representing YouTube player errors.
NSString static *const kBBYoutubePlayerErrorInvalidParamErrorCode = @"2";
NSString static *const kBBYoutubePlayerErrorHTML5ErrorCode = @"5";
NSString static *const kBBYoutubePlayerErrorVideoNotFoundErrorCode = @"100";
NSString static *const kBBYoutubePlayerErrorNotEmbeddableErrorCode = @"101";
NSString static *const kBBYoutubePlayerErrorCannotFindVideoErrorCode = @"105";
NSString static *const kBBYoutubePlayerErrorSameAsNotEmbeddableErrorCode = @"150";

// Constants representing player callbacks.
NSString static *const kBBYoutubePlayerCallbackOnReady = @"onReady";
NSString static *const kBBYoutubePlayerCallbackOnStateChange = @"onStateChange";
NSString static *const kBBYoutubePlayerCallbackOnPlaybackQualityChange = @"onPlaybackQualityChange";
NSString static *const kBBYoutubePlayerCallbackOnError = @"onError";
NSString static *const kBBYoutubePlayerCallbackOnPlayTime = @"onPlayTime";

NSString static *const kBBYoutubePlayerCallbackOnYouTubeIframeAPIReady = @"onYouTubeIframeAPIReady";

NSString static *const kBBYoutubePlayerEmbedUrlRegexPattern = @"^http(s)://(www.)youtube.com/embed/(.*)$";
NSString static *const kBBYoutubePlayerAdUrlRegexPattern = @"^http(s)://pubads.g.doubleclick.net/pagead/conversion/";
NSString static *const kBBYoutubePlayerOAuthRegexPattern = @"^http(s)://accounts.google.com/o/oauth2/(.*)$";
NSString static *const kBBYoutubePlayerStaticProxyRegexPattern = @"^https://content.googleapis.com/static/proxy.html(.*)$";

@interface BBYoutubePlayerView()

@property(nonatomic, strong) NSURL *originURL;

@end

@implementation BBYoutubePlayerView

- (BOOL)loadWithVideoId:(NSString *)videoId {
    return [self loadWithVideoId:videoId playerVars:nil];
}

- (BOOL)loadWithPlaylistId:(NSString *)playlistId {
    return [self loadWithPlaylistId:playlistId playerVars:nil];
}

- (BOOL)loadWithVideoId:(NSString *)videoId playerVars:(NSDictionary *)playerVars {
    if (!playerVars) {
        playerVars = @{};
    }
    NSDictionary *playerParams = @{ @"videoId" : videoId, @"playerVars" : playerVars };
    return [self loadWithPlayerParams:playerParams];
}

- (BOOL)loadWithPlaylistId:(NSString *)playlistId playerVars:(NSDictionary *)playerVars {
    
    // Mutable copy because we may have been passed an immutable config dictionary.
    NSMutableDictionary *tempPlayerVars = [[NSMutableDictionary alloc] init];
    [tempPlayerVars setValue:@"playlist" forKey:@"listType"];
    [tempPlayerVars setValue:playlistId forKey:@"list"];
    [tempPlayerVars addEntriesFromDictionary:playerVars];  // No-op if playerVars is null
    
    NSDictionary *playerParams = @{ @"playerVars" : tempPlayerVars };
    return [self loadWithPlayerParams:playerParams];
}

#pragma mark - Player methods

- (void)playVideo {
    [self stringFromEvaluatingJavaScript:@"player.playVideo();"];
}

- (void)pauseVideo {
    [self notifyDelegateOfYouTubeCallbackUrl:[NSURL URLWithString:[NSString stringWithFormat:@"ytplayer://onStateChange?data=%@", kBBYoutubePlayerStatePausedCode]]];
    [self stringFromEvaluatingJavaScript:@"player.pauseVideo();"];
}

- (void)stopVideo {
    [self stringFromEvaluatingJavaScript:@"player.stopVideo();"];
}

- (void)seekToSeconds:(float)seekToSeconds allowSeekAhead:(BOOL)allowSeekAhead {
    NSNumber *secondsValue = [NSNumber numberWithFloat:seekToSeconds];
    NSString *allowSeekAheadValue = [self stringForJSBoolean:allowSeekAhead];
    NSString *command = [NSString stringWithFormat:@"player.seekTo(%@, %@);", secondsValue, allowSeekAheadValue];
    [self stringFromEvaluatingJavaScript:command];
}

- (void)clearVideo {
    [self stringFromEvaluatingJavaScript:@"player.clearVideo();"];
}

#pragma mark - Cueing methods

- (void)cueVideoById:(NSString *)videoId
        startSeconds:(float)startSeconds
    suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.cueVideoById('%@', %@, '%@');",
                         videoId, startSecondsValue, qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

- (void)cueVideoById:(NSString *)videoId
        startSeconds:(float)startSeconds
          endSeconds:(float)endSeconds
    suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.cueVideoById({'videoId': '%@', 'startSeconds': %@, 'endSeconds': %@, 'suggestedQuality': '%@'});", videoId, startSecondsValue, endSecondsValue, qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

- (void)loadVideoById:(NSString *)videoId
         startSeconds:(float)startSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.loadVideoById('%@', %@, '%@');",
                         videoId, startSecondsValue, qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

- (void)loadVideoById:(NSString *)videoId
         startSeconds:(float)startSeconds
           endSeconds:(float)endSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.loadVideoById({'videoId': '%@', 'startSeconds': %@, 'endSeconds': %@, 'suggestedQuality': '%@'});",videoId, startSecondsValue, endSecondsValue, qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

- (void)cueVideoByURL:(NSString *)videoURL
         startSeconds:(float)startSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.cueVideoByUrl('%@', %@, '%@');",
                         videoURL, startSecondsValue, qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

- (void)cueVideoByURL:(NSString *)videoURL
         startSeconds:(float)startSeconds
           endSeconds:(float)endSeconds
     suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.cueVideoByUrl('%@', %@, %@, '%@');",
                         videoURL, startSecondsValue, endSecondsValue, qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

- (void)loadVideoByURL:(NSString *)videoURL
          startSeconds:(float)startSeconds
      suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.loadVideoByUrl('%@', %@, '%@');",
                         videoURL, startSecondsValue, qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

- (void)loadVideoByURL:(NSString *)videoURL
          startSeconds:(float)startSeconds
            endSeconds:(float)endSeconds
      suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSNumber *endSecondsValue = [NSNumber numberWithFloat:endSeconds];
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.loadVideoByUrl('%@', %@, %@, '%@');",
                         videoURL, startSecondsValue, endSecondsValue, qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

#pragma mark - Cueing methods for lists

- (void)cuePlaylistByPlaylistId:(NSString *)playlistId
                          index:(int)index
                   startSeconds:(float)startSeconds
               suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSString *playlistIdString = [NSString stringWithFormat:@"'%@'", playlistId];
    [self cuePlaylist:playlistIdString
                index:index
         startSeconds:startSeconds
     suggestedQuality:suggestedQuality];
}

- (void)cuePlaylistByVideos:(NSArray *)videoIds
                      index:(int)index
               startSeconds:(float)startSeconds
           suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    [self cuePlaylist:[self stringFromVideoIdArray:videoIds]
                index:index
         startSeconds:startSeconds
     suggestedQuality:suggestedQuality];
}

- (void)loadPlaylistByPlaylistId:(NSString *)playlistId
                           index:(int)index
                    startSeconds:(float)startSeconds
                suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSString *playlistIdString = [NSString stringWithFormat:@"'%@'", playlistId];
    [self loadPlaylist:playlistIdString
                 index:index
          startSeconds:startSeconds
      suggestedQuality:suggestedQuality];
}

- (void)loadPlaylistByVideos:(NSArray *)videoIds
                       index:(int)index
                startSeconds:(float)startSeconds
            suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    [self loadPlaylist:[self stringFromVideoIdArray:videoIds]
                 index:index
          startSeconds:startSeconds
      suggestedQuality:suggestedQuality];
}

#pragma mark - Setting the playback rate

- (float)playbackRate {
    NSString *returnValue = [self stringFromEvaluatingJavaScript:@"player.getPlaybackRate();"];
    return [returnValue floatValue];
}

- (void)setPlaybackRate:(float)suggestedRate {
    NSString *command = [NSString stringWithFormat:@"player.setPlaybackRate(%f);", suggestedRate];
    [self stringFromEvaluatingJavaScript:command];
}

- (NSArray *)availablePlaybackRates {
    NSString *returnValue =
    [self stringFromEvaluatingJavaScript:@"player.getAvailablePlaybackRates();"];
    
    NSData *playbackRateData = [returnValue dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonDeserializationError;
    NSArray *playbackRates = [NSJSONSerialization JSONObjectWithData:playbackRateData
                                                             options:kNilOptions
                                                               error:&jsonDeserializationError];
    if (jsonDeserializationError) {
        return nil;
    }
    
    return playbackRates;
}

#pragma mark - Setting playback behavior for playlists

- (void)setLoop:(BOOL)loop {
    NSString *loopPlayListValue = [self stringForJSBoolean:loop];
    NSString *command = [NSString stringWithFormat:@"player.setLoop(%@);", loopPlayListValue];
    [self stringFromEvaluatingJavaScript:command];
}

- (void)setShuffle:(BOOL)shuffle {
    NSString *shufflePlayListValue = [self stringForJSBoolean:shuffle];
    NSString *command = [NSString stringWithFormat:@"player.setShuffle(%@);", shufflePlayListValue];
    [self stringFromEvaluatingJavaScript:command];
}

#pragma mark - Playback status

- (float)videoLoadedFraction {
    return [[self stringFromEvaluatingJavaScript:@"player.getVideoLoadedFraction();"] floatValue];
}

- (YTPlayerState)playerState {
    NSString *returnValue = [self stringFromEvaluatingJavaScript:@"player.getPlayerState();"];
    return [BBYoutubePlayerView playerStateForString:returnValue];
}

- (float)currentTime {
    return [[self stringFromEvaluatingJavaScript:@"player.getCurrentTime();"] floatValue];
}

// Playback quality
- (YTPlaybackQuality)playbackQuality {
    NSString *qualityValue = [self stringFromEvaluatingJavaScript:@"player.getPlaybackQuality();"];
    return [BBYoutubePlayerView playbackQualityForString:qualityValue];
}

- (void)setPlaybackQuality:(YTPlaybackQuality)suggestedQuality {
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.setPlaybackQuality('%@');", qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

#pragma mark - Video information methods

- (NSTimeInterval)duration {
    return [[self stringFromEvaluatingJavaScript:@"player.getDuration();"] doubleValue];
}

- (NSURL *)videoUrl {
    return [NSURL URLWithString:[self stringFromEvaluatingJavaScript:@"player.getVideoUrl();"]];
}

- (NSString *)videoEmbedCode {
    return [self stringFromEvaluatingJavaScript:@"player.getVideoEmbedCode();"];
}

#pragma mark - Playlist methods

- (NSArray *)playlist {
    NSString *returnValue = [self stringFromEvaluatingJavaScript:@"player.getPlaylist();"];
    
    NSData *playlistData = [returnValue dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonDeserializationError;
    NSArray *videoIds = [NSJSONSerialization JSONObjectWithData:playlistData
                                                        options:kNilOptions
                                                          error:&jsonDeserializationError];
    if (jsonDeserializationError) {
        return nil;
    }
    
    return videoIds;
}

- (int)playlistIndex {
    NSString *returnValue = [self stringFromEvaluatingJavaScript:@"player.getPlaylistIndex();"];
    return [returnValue intValue];
}

#pragma mark - Playing a video in a playlist

- (void)nextVideo {
    [self stringFromEvaluatingJavaScript:@"player.nextVideo();"];
}

- (void)previousVideo {
    [self stringFromEvaluatingJavaScript:@"player.previousVideo();"];
}

- (void)playVideoAt:(int)index {
    NSString *command =
    [NSString stringWithFormat:@"player.playVideoAt(%@);", [NSNumber numberWithInt:index]];
    [self stringFromEvaluatingJavaScript:command];
}

#pragma mark - Help methods

- (NSArray *)availableQualityLevels {
    NSString *returnValue =
    [self stringFromEvaluatingJavaScript:@"player.getAvailableQualityLevels().toString();"];
    if(!returnValue) return nil;
    
    NSArray *rawQualityValues = [returnValue componentsSeparatedByString:@","];
    NSMutableArray *levels = [[NSMutableArray alloc] init];
    for (NSString *rawQualityValue in rawQualityValues) {
        YTPlaybackQuality quality = [BBYoutubePlayerView playbackQualityForString:rawQualityValue];
        [levels addObject:[NSNumber numberWithInt:quality]];
    }
    return levels;
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.host isEqual: self.originURL.host]) {
        return YES;
    } else if ([request.URL.scheme isEqual:@"ytplayer"]) {
        [self notifyDelegateOfYouTubeCallbackUrl:request.URL];
        return NO;
    } else if ([request.URL.scheme isEqual: @"http"] || [request.URL.scheme isEqual:@"https"]) {
        return [self handleHttpNavigationToUrl:request.URL];
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

/**
 * Convert a quality value from NSString to the typed enum value.
 *
 * @param qualityString A string representing playback quality. Ex: "small", "medium", "hd1080".
 * @return An enum value representing the playback quality.
 */
+ (YTPlaybackQuality)playbackQualityForString:(NSString *)qualityString {
    YTPlaybackQuality quality = kBBYoutubePlaybackQualityUnknown;
    
    if ([qualityString isEqualToString:kBBYoutubePlaybackQualitySmallQuality]) {
        quality = kBBYoutubePlaybackQualitySmall;
    } else if ([qualityString isEqualToString:kBBYoutubePlaybackQualityMediumQuality]) {
        quality = kBBYoutubePlaybackQualityMedium;
    } else if ([qualityString isEqualToString:kBBYoutubePlaybackQualityLargeQuality]) {
        quality = kBBYoutubePlaybackQualityLarge;
    } else if ([qualityString isEqualToString:kBBYoutubePlaybackQualityHD720Quality]) {
        quality = kBBYoutubePlaybackQualityHD720;
    } else if ([qualityString isEqualToString:kBBYoutubePlaybackQualityHD1080Quality]) {
        quality = kBBYoutubePlaybackQualityHD1080;
    } else if ([qualityString isEqualToString:kBBYoutubePlaybackQualityHighResQuality]) {
        quality = kBBYoutubePlaybackQualityHighRes;
    } else if ([qualityString isEqualToString:kBBYoutubePlaybackQualityAutoQuality]) {
        quality = kBBYoutubePlaybackQualityAuto;
    }
    
    return quality;
}

/**
 * Convert a |YTPlaybackQuality| value from the typed value to NSString.
 *
 * @param quality A |YTPlaybackQuality| parameter.
 * @return An |NSString| value to be used in the JavaScript bridge.
 */
+ (NSString *)stringForPlaybackQuality:(YTPlaybackQuality)quality {
    switch (quality) {
        case kBBYoutubePlaybackQualitySmall:
            return kBBYoutubePlaybackQualitySmallQuality;
        case kBBYoutubePlaybackQualityMedium:
            return kBBYoutubePlaybackQualityMediumQuality;
        case kBBYoutubePlaybackQualityLarge:
            return kBBYoutubePlaybackQualityLargeQuality;
        case kBBYoutubePlaybackQualityHD720:
            return kBBYoutubePlaybackQualityHD720Quality;
        case kBBYoutubePlaybackQualityHD1080:
            return kBBYoutubePlaybackQualityHD1080Quality;
        case kBBYoutubePlaybackQualityHighRes:
            return kBBYoutubePlaybackQualityHighResQuality;
        case kBBYoutubePlaybackQualityAuto:
            return kBBYoutubePlaybackQualityAutoQuality;
        default:
            return kBBYoutubePlaybackQualityUnknownQuality;
    }
}

/**
 * Convert a state value from NSString to the typed enum value.
 *
 * @param stateString A string representing player state. Ex: "-1", "0", "1".
 * @return An enum value representing the player state.
 */
+ (YTPlayerState)playerStateForString:(NSString *)stateString {
    YTPlayerState state = kBBYoutubePlayerStateUnknown;
    if ([stateString isEqualToString:kBBYoutubePlayerStateUnstartedCode]) {
        state = kBBYoutubePlayerStateUnstarted;
    } else if ([stateString isEqualToString:kBBYoutubePlayerStateEndedCode]) {
        state = kBBYoutubePlayerStateEnded;
    } else if ([stateString isEqualToString:kBBYoutubePlayerStatePlayingCode]) {
        state = kBBYoutubePlayerStatePlaying;
    } else if ([stateString isEqualToString:kBBYoutubePlayerStatePausedCode]) {
        state = kBBYoutubePlayerStatePaused;
    } else if ([stateString isEqualToString:kBBYoutubePlayerStateBufferingCode]) {
        state = kBBYoutubePlayerStateBuffering;
    } else if ([stateString isEqualToString:kBBYoutubePlayerStateCuedCode]) {
        state = kBBYoutubePlayerStateQueued;
    }
    return state;
}

/**
 * Convert a state value from the typed value to NSString.
 *
 * @param state A |YTPlayerState| parameter.
 * @return A string value to be used in the JavaScript bridge.
 */
+ (NSString *)stringForPlayerState:(YTPlayerState)state {
    switch (state) {
        case kBBYoutubePlayerStateUnstarted:
            return kBBYoutubePlayerStateUnstartedCode;
        case kBBYoutubePlayerStateEnded:
            return kBBYoutubePlayerStateEndedCode;
        case kBBYoutubePlayerStatePlaying:
            return kBBYoutubePlayerStatePlayingCode;
        case kBBYoutubePlayerStatePaused:
            return kBBYoutubePlayerStatePausedCode;
        case kBBYoutubePlayerStateBuffering:
            return kBBYoutubePlayerStateBufferingCode;
        case kBBYoutubePlayerStateQueued:
            return kBBYoutubePlayerStateCuedCode;
        default:
            return kBBYoutubePlayerStateUnknownCode;
    }
}

#pragma mark - Private methods

/**
 * Private method to handle "navigation" to a callback URL of the format
 * ytplayer://action?data=someData
 * This is how the UIWebView communicates with the containing Objective-C code.
 * Side effects of this method are that it calls methods on this class's delegate.
 *
 * @param url A URL of the format ytplayer://action?data=value.
 */
- (void)notifyDelegateOfYouTubeCallbackUrl: (NSURL *) url {
    NSString *action = url.host;
    
    // We know the query can only be of the format ytplayer://action?data=SOMEVALUE,
    // so we parse out the value.
    NSString *query = url.query;
    NSString *data;
    if (query) {
        data = [query componentsSeparatedByString:@"="][1];
    }
    
    if ([action isEqual:kBBYoutubePlayerCallbackOnReady]) {
        if ([self.delegate respondsToSelector:@selector(playerViewDidBecomeReady:)]) {
            [self.delegate playerViewDidBecomeReady:self];
        }
    } else if ([action isEqual:kBBYoutubePlayerCallbackOnStateChange]) {
        if ([self.delegate respondsToSelector:@selector(playerView:didChangeToState:)]) {
            YTPlayerState state = kBBYoutubePlayerStateUnknown;
            
            if ([data isEqual:kBBYoutubePlayerStateEndedCode]) {
                state = kBBYoutubePlayerStateEnded;
            } else if ([data isEqual:kBBYoutubePlayerStatePlayingCode]) {
                state = kBBYoutubePlayerStatePlaying;
            } else if ([data isEqual:kBBYoutubePlayerStatePausedCode]) {
                state = kBBYoutubePlayerStatePaused;
            } else if ([data isEqual:kBBYoutubePlayerStateBufferingCode]) {
                state = kBBYoutubePlayerStateBuffering;
            } else if ([data isEqual:kBBYoutubePlayerStateCuedCode]) {
                state = kBBYoutubePlayerStateQueued;
            } else if ([data isEqual:kBBYoutubePlayerStateUnstartedCode]) {
                state = kBBYoutubePlayerStateUnstarted;
            }
            
            [self.delegate playerView:self didChangeToState:state];
        }
    } else if ([action isEqual:kBBYoutubePlayerCallbackOnPlaybackQualityChange]) {
        if ([self.delegate respondsToSelector:@selector(playerView:didChangeToQuality:)]) {
            YTPlaybackQuality quality = [BBYoutubePlayerView playbackQualityForString:data];
            [self.delegate playerView:self didChangeToQuality:quality];
        }
    } else if ([action isEqual:kBBYoutubePlayerCallbackOnError]) {
        if ([self.delegate respondsToSelector:@selector(playerView:receivedError:)]) {
            YTPlayerError error = kBBYoutubePlayerErrorUnknown;
            
            if ([data isEqual:kBBYoutubePlayerErrorInvalidParamErrorCode]) {
                error = kBBYoutubePlayerErrorInvalidParam;
            } else if ([data isEqual:kBBYoutubePlayerErrorHTML5ErrorCode]) {
                error = kBBYoutubePlayerErrorHTML5Error;
            } else if ([data isEqual:kBBYoutubePlayerErrorNotEmbeddableErrorCode] ||
                       [data isEqual:kBBYoutubePlayerErrorSameAsNotEmbeddableErrorCode]) {
                error = kBBYoutubePlayerErrorNotEmbeddable;
            } else if ([data isEqual:kBBYoutubePlayerErrorVideoNotFoundErrorCode] ||
                       [data isEqual:kBBYoutubePlayerErrorCannotFindVideoErrorCode]) {
                error = kBBYoutubePlayerErrorVideoNotFound;
            }
            
            [self.delegate playerView:self receivedError:error];
        }
    } else if ([action isEqualToString:kBBYoutubePlayerCallbackOnPlayTime]) {
        if ([self.delegate respondsToSelector:@selector(playerView:didPlayTime:)]) {
            float time = [data floatValue];
            [self.delegate playerView:self didPlayTime:time];
        }
        
    }
}

- (BOOL)handleHttpNavigationToUrl:(NSURL *) url {
    // Usually this means the user has clicked on the YouTube logo or an error message in the
    // player. Most URLs should open in the browser. The only http(s) URL that should open in this
    // UIWebView is the URL for the embed, which is of the format:
    //     http(s)://www.youtube.com/embed/[VIDEO ID]?[PARAMETERS]
    NSError *error = NULL;
    NSRegularExpression *ytRegex =
    [NSRegularExpression regularExpressionWithPattern:kBBYoutubePlayerEmbedUrlRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSTextCheckingResult *ytMatch =
    [ytRegex firstMatchInString:url.absoluteString
                        options:0
                          range:NSMakeRange(0, [url.absoluteString length])];
    
    NSRegularExpression *adRegex =
    [NSRegularExpression regularExpressionWithPattern:kBBYoutubePlayerAdUrlRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSTextCheckingResult *adMatch =
    [adRegex firstMatchInString:url.absoluteString
                        options:0
                          range:NSMakeRange(0, [url.absoluteString length])];
    
    NSRegularExpression *oauthRegex =
    [NSRegularExpression regularExpressionWithPattern:kBBYoutubePlayerOAuthRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSTextCheckingResult *oauthMatch =
    [oauthRegex firstMatchInString:url.absoluteString
                           options:0
                             range:NSMakeRange(0, [url.absoluteString length])];
    
    NSRegularExpression *staticProxyRegex =
    [NSRegularExpression regularExpressionWithPattern:kBBYoutubePlayerStaticProxyRegexPattern
                                              options:NSRegularExpressionCaseInsensitive
                                                error:&error];
    NSTextCheckingResult *staticProxyMatch =
    [staticProxyRegex firstMatchInString:url.absoluteString
                                 options:0
                                   range:NSMakeRange(0, [url.absoluteString length])];
    
    if (ytMatch || adMatch || oauthMatch || staticProxyMatch) {
        return YES;
    } else {
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
}


/**
 * Private help method to load an iframe player with the given player parameters.
 *
 * @param additionalPlayerParams An NSDictionary of parameters in addition to required parameters
 *                               to instantiate the HTML5 player with. This differs depending on
 *                               whether a single video or playlist is being loaded.
 * @return YES if successful, NO if not.
 */
- (BOOL)loadWithPlayerParams:(NSDictionary *)additionalPlayerParams {
    NSDictionary *playerCallbacks = @{
                                      @"onReady" : @"onReady",
                                      @"onStateChange" : @"onStateChange",
                                      @"onPlaybackQualityChange" : @"onPlaybackQualityChange",
                                      @"onError" : @"onPlayerError"
                                      };
    NSMutableDictionary *playerParams = [[NSMutableDictionary alloc] init];
    [playerParams addEntriesFromDictionary:additionalPlayerParams];
    if (![playerParams objectForKey:@"height"]) {
        [playerParams setValue:@"100%" forKey:@"height"];
    }
    if (![playerParams objectForKey:@"width"]) {
        [playerParams setValue:@"100%" forKey:@"width"];
    }
    
    [playerParams setValue:playerCallbacks forKey:@"events"];
    
    if ([playerParams objectForKey:@"playerVars"]) {
        NSMutableDictionary *playerVars = [[NSMutableDictionary alloc] init];
        [playerVars addEntriesFromDictionary:[playerParams objectForKey:@"playerVars"]];
        
        if (![playerVars objectForKey:@"origin"]) {
            self.originURL = [NSURL URLWithString:@"about:blank"];
        } else {
            self.originURL = [NSURL URLWithString: [playerVars objectForKey:@"origin"]];
        }
    } else {
        // This must not be empty so we can render a '{}' in the output JSON
        [playerParams setValue:[[NSDictionary alloc] init] forKey:@"playerVars"];
    }
    
    // Remove the existing webView to reset any state
    [self.webView removeFromSuperview];
    _webView = [self createNewWebView];
    [self addSubview:self.webView];
    
    NSString *embedHTMLTemplate = [self embedHTMLTemplate];    
    // Render the playerVars as a JSON dictionary.
    NSError *jsonRenderingError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:playerParams
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonRenderingError];
    if (jsonRenderingError) {
        NSLog(@"Attempted configuration of player with invalid playerVars: %@ \tError: %@",
              playerParams,
              jsonRenderingError);
        return NO;
    }
    
    NSString *playerVarsJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *embedHTML = [NSString stringWithFormat:embedHTMLTemplate, playerVarsJsonString];
    [self.webView loadHTMLString:embedHTML baseURL: self.originURL];
    [self.webView setDelegate:self];
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    return YES;
}

- (NSString *)embedHTMLTemplate {
    
    return @"<!DOCTYPE html>\n\
    <html>\n\
    <head>\n\
    <style>\n\
    body { margin: 0; width:100%%; height:100%%;  background-color:#000000; }\n\
    html { width:100%%; height:100%%; background-color:#000000; }\n\
        .embed-container iframe,\n\
        .embed-container object,\n\
        .embed-container embed {\n\
        position: absolute;\n\
        top: 0;\n\
        left: 0;\n\
        width: 100%% !important;\n\
        height: 100%% !important;\n\
    }\n\
    </style>\n</head>\n<body>\n\
    <div class=\"embed-container\">\n\
    <div id=\"player\"></div>\n\
    </div>\n\
    \n\
    <script src=\"https://www.youtube.com/iframe_api\"></script>\n\
    <script>\n\
    var player;\n\
    var error = false;\n\
    \n\
    YT.ready(function() {\n\
        player = new YT.Player('player', %@);\n\
        player.setSize(window.innerWidth, window.innerHeight);\n\
        window.location.href = 'ytplayer://onYouTubeIframeAPIReady';\n\
        // this will transmit playTime frequently while playng\n\
        function getCurrentTime() {\n\
            var state = player.getPlayerState();\n\
            if (state == YT.PlayerState.PLAYING) {\n\
                time = player.getCurrentTime()\n\
                window.location.href = 'ytplayer://onPlayTime?data=' + time;\n\
            }\n\
        }\n\
        window.setInterval(getCurrentTime, 500);\n\
        \n\
    });\n\
    \n\
    function onReady(event) {\n\
        window.location.href = 'ytplayer://onReady?data=' + event.data;\n\
    }\n\
    \n\
    function onStateChange(event) {\n\
        if (!error) {\n\
            window.location.href = 'ytplayer://onStateChange?data=' + event.data;\n\
        }\n\
        else {\n\
            error = false;\n\
        }\n\
    }\n\
    \n\
    function onPlaybackQualityChange(event) {\n\
        window.location.href = 'ytplayer://onPlaybackQualityChange?data=' + event.data;\n\
    }\n\
    \n\
    function onPlayerError(event) {\n\
        if (event.data == 100) {\n\
            error = true;\n\
        }\n\
        window.location.href = 'ytplayer://onError?data=' + event.data;\n\
    }\n\
    \n\
    window.onresize = function() {\n\
        player.setSize(window.innerWidth, window.innerHeight);\n\
    }\n\
    \n\
    </script>\n\
    </body>\n\
    </html>";
}

/**
 * Private method for cueing both cases of playlist ID and array of video IDs. Cueing
 * a playlist does not start playback.
 *
 * @param cueingString A JavaScript string representing an array, playlist ID or list of
 *                     video IDs to play with the playlist player.
 * @param index 0-index position of video to start playback on.
 * @param startSeconds Seconds after start of video to begin playback.
 * @param suggestedQuality Suggested YTPlaybackQuality to play the videos.
 *
 */
- (void)cuePlaylist:(NSString *)cueingString
              index:(int)index
       startSeconds:(float)startSeconds
   suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *indexValue = [NSNumber numberWithInt:index];
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.cuePlaylist(%@, %@, %@, '%@');",
                         cueingString, indexValue, startSecondsValue, qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

/**
 * Private method for loading both cases of playlist ID and array of video IDs. Loading
 * a playlist automatically starts playback.
 *
 * @param cueingString A JavaScript string representing an array, playlist ID or list of
 *                     video IDs to play with the playlist player.
 * @param index 0-index position of video to start playback on.
 * @param startSeconds Seconds after start of video to begin playback.
 * @param suggestedQuality Suggested YTPlaybackQuality to play the videos.
 *
 */
- (void)loadPlaylist:(NSString *)cueingString
               index:(int)index
        startSeconds:(float)startSeconds
    suggestedQuality:(YTPlaybackQuality)suggestedQuality {
    NSNumber *indexValue = [NSNumber numberWithInt:index];
    NSNumber *startSecondsValue = [NSNumber numberWithFloat:startSeconds];
    NSString *qualityValue = [BBYoutubePlayerView stringForPlaybackQuality:suggestedQuality];
    NSString *command = [NSString stringWithFormat:@"player.loadPlaylist(%@, %@, %@, '%@');",
                         cueingString, indexValue, startSecondsValue, qualityValue];
    [self stringFromEvaluatingJavaScript:command];
}

/**
 * Private help method for converting an NSArray of video IDs into its JavaScript equivalent.
 *
 * @param videoIds An array of video ID strings to convert into JavaScript format.
 * @return A JavaScript array in String format containing video IDs.
 */
- (NSString *)stringFromVideoIdArray:(NSArray *)videoIds {
    NSMutableArray *formattedVideoIds = [[NSMutableArray alloc] init];
    
    for (id unformattedId in videoIds) {
        [formattedVideoIds addObject:[NSString stringWithFormat:@"'%@'", unformattedId]];
    }
    
    return [NSString stringWithFormat:@"[%@]", [formattedVideoIds componentsJoinedByString:@", "]];
}

/**
 * Private method for evaluating JavaScript in the WebView.
 *
 * @param jsToExecute The JavaScript code in string format that we want to execute.
 * @return JavaScript response from evaluating code.
 */
- (NSString *)stringFromEvaluatingJavaScript:(NSString *)jsToExecute {
    return [self.webView stringByEvaluatingJavaScriptFromString:jsToExecute];
}

/**
 * Private method to convert a Objective-C BOOL value to JS boolean value.
 *
 * @param boolValue Objective-C BOOL value.
 * @return JavaScript Boolean value, i.e. "true" or "false".
 */
- (NSString *)stringForJSBoolean:(BOOL)boolValue {
    return boolValue ? @"true" : @"false";
}

#pragma mark Exposed for Testing
- (void)setWebView:(UIWebView *)webView {
    _webView = webView;
}

- (UIWebView *)createNewWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    webView.scrollView.scrollEnabled = NO;
    webView.scrollView.bounces = NO;
    return webView;
}

- (void)removeWebView {
    [self.webView removeFromSuperview];
    self.webView = nil;
}

+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Assets.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

@end
