# cordova-plugin-iflyspeech #

This plugin provides the ability to speech recognition and synthesis (over iFlytek voicecloud) on a device.

## Installation

	cordova plugin add com.rjfun.cordova.plugin.iflyspeech

Or,
	
	cordova plugin add https://github.com/floatinghotpot/cordova-plugin-iflyspeech.git

Attentioin: You need apply an App Id and SDK from http://open.voicecloud.cn/.

Please replace:
- the iFlytek SDK files(ios/iflyMSC.framework and android/libs) with the version for your app.
- the SPEECH_APP_ID in ios/CDVSpeech.m and android/Speech.java

## Supported Platforms ##

* Android
* iOS

## Javascript APIs ##

    speech.addEventListener( event_name, your_callback );
    speech.removeEventListener( event_name );

    speech.startListening();
    speech.stopListening();
    speech.cancelListening();
    
    speech.startSpeaking( what_to_say, options );
    speech.pauseSpeaking();
    speech.resumeSpeaking();
    speech.stopSpeaking();
    
    speech.onSpeak( your_callback_func );

## Events ##
    
    SpeechBegin
    SpeechEnd
    SpeechCancel
    SpeechResults
    SpeechError  
    VolumeChanged

    SpeakBegin
    SpeakPaused
    SpeakResumed
    SpeakCancel
    SpeakCompleted 
    SpeakProgress
    BufferProgress
    
## Quick Start ##

Copy the example code under test/ to your www/, and build to play.

	cordova create testspeech com.rjfun.testspeech TestSpeech
	cd testspeech
	cordova platform add android
	cordova platform add ios
	cordova plugin add https://github.com/floatinghotpot/cordova-plugin-iflyspeech.git
	rm -r www/*
	cp -r plugins/com.rjfun.cordova.plugin.iflyspeech/test/* www/
	cordova prepare; cordova run android; cordova run ios;
	// or import the project into Xcode or eclipse

## Example Code ##
```javascript
function onLoad() {
    document.addEventListener("deviceready", onDeviceReady, false);
}
function onDeviceReady() {
	navigator.speech.onSpeak( function(str) {
		// this is what the device hear and understand
	    $('textarea#read').val( str );
	    $('div#status').html( str );
	});
	
	// enumrate the available voice names to a drop down list.
	var s = navigator.speech.voice_names;
	for( var v in s ) {
	    $('select#voice_name').append( new Option(s[v], v) );
	}
	
	$('div#status').html( 'speech engine ready' );
}
function startReading() {
	var text = $('textarea#read').val();

	var speakers = $('select#voice_name')[0];
	var speaker = speakers.options[ speakers.selectedIndex ];
	var speaker_name = speaker.innerHTML;
	var options = {voice_name: speaker.value};
	$('div#status').html( speaker_name + '：' + text );

	navigator.speech.startSpeaking( text, options );
}
function stopReading() {
	navigator.speech.stopSpeaking();
}
function startListening() {
	$('div#status').html( 'start listening, please speak.' );

	navigator.speech.startListening();
}
function stopListening() {
	navigator.speech.stopListening();
}
```

## Credit ##

This plugin code was based on project of Lu Huiguo. His code is very good but not tuned to work. It seems that he is not very active, so I start a new repository.

 
