package com.rjfun.cordova.plugin;

import java.util.Iterator;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.text.TextUtils;
import android.util.Log;

import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.SpeechSynthesizer;
import com.iflytek.cloud.SpeechUtility;
import com.iflytek.cloud.SynthesizerListener;

/**
 * This class echoes a string called from JavaScript.
 */
public class Speech extends CordovaPlugin implements RecognizerListener, SynthesizerListener {
	private static final String LOGTAG = "SpeechPlugin";

    public static final String STR_EVENT = "event";
    public static final String STR_CODE = "code";
    public static final String STR_MESSAGE = "message";
    public static final String STR_VOLUME = "volume";
    public static final String STR_RESULTS = "results";
    public static final String STR_PROGRESS = "progress";

    public static final String EVENT_SPEECH_ERROR = "SpeechError";
    public static final String EVENT_SPEECH_RESULTS = "SpeechResults";
    public static final String EVENT_VOLUME_CHANGED = "VolumeChanged";
    public static final String EVENT_SPEECH_BEGIN = "SpeechBegin";
    public static final String EVENT_SPEECH_END = "SpeechEnd";
    public static final String EVENT_SPEECH_CANCEL = "SpeechCancel";

    public static final String EVENT_SPEAK_COMPLETED = "SpeakCompleted";
    public static final String EVENT_SPEAK_BEGIN = "SpeakBegin";
    public static final String EVENT_SPEAK_PAUSED = "SpeakPaused";
    public static final String EVENT_SPEAK_RESUMED = "SpeakResumed";
    public static final String EVENT_SPEAK_CANCEL = "SpeakCancel";
    public static final String EVENT_SPEAK_PROGRESS = "SpeakProgress";
    public static final String EVENT_BUFFER_PROGRESS = "BufferProgress";
    
    // TODO: always replace the appId and the SDK with what you get from voicecloud.cn
    private static final String SPEECH_APP_ID = "53cba6e2";
    
    private CallbackContext callback;
    private SpeechRecognizer recognizer;
    private SpeechSynthesizer synthesizer;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("login")) {
            this.login(callbackContext);
            
        } else if (action.equals("startListening")) {
            JSONObject options = args.optJSONObject(0);
            this.startListening(options, callbackContext);
            
        } else if (action.equals("stopListening")) {
            this.stopListening(callbackContext);
            
        } else if (action.equals("cancelListening")) {
            this.cancelListening(callbackContext);
            
        } else if (action.equals("startSpeaking")) {
            String text = args.getString(0);
            JSONObject options = args.optJSONObject(1);
            this.startSpeaking(text, options, callbackContext);
            
        } else if (action.equals("pauseSpeaking")) {
            this.pauseSpeaking(callbackContext);
            
        } else if (action.equals("resumeSpeaking")) {
            this.resumeSpeaking(callbackContext);
            
        } else if (action.equals("stopSpeaking")) {
            this.stopSpeaking(callbackContext);
            
        } else { // Unrecognized action.
            return false;
        }

        return true;
    }

    private SpeechRecognizer getRecognizer() {
        if (recognizer == null) {
            recognizer = SpeechRecognizer.createRecognizer(this.cordova.getActivity(), null);
        }
        return recognizer;
    }

    private SpeechSynthesizer getSynthesizer() {
        if (synthesizer == null) {
            synthesizer = SpeechSynthesizer.createSynthesizer(this.cordova.getActivity(), null);
        }
        return synthesizer;
    }

    private void login(CallbackContext callbackContext) {
        this.callback = callbackContext;
        SpeechUtility.createUtility(cordova.getActivity(), SpeechConstant.APPID +"=" + SPEECH_APP_ID);
    }

    private void startListening(JSONObject options, CallbackContext callbackContext) {
        getRecognizer().setParameter(SpeechConstant.DOMAIN, "iat");
        getRecognizer().setParameter(SpeechConstant.LANGUAGE, "zh_cn");
        getRecognizer().setParameter(SpeechConstant.ACCENT, "mandarin ");
        
        //getRecognizer().setParameter(SpeechConstant.SAMPLE_RATE, "8000");
        //getRecognizer().setParameter(SpeechConstant.ASR_AUDIO_PATH,"./sdcard/asr.pcm");

        if (options != null) {
            while (options.keys().hasNext()) {
                String key = (String) options.keys().next();
                String value = options.optString(key);
                getRecognizer().setParameter(key, value);
            }
        }

        getRecognizer().startListening(this);
    }

    private void stopListening(CallbackContext callbackContext) {
        getRecognizer().stopListening();
    }

    private void cancelListening(CallbackContext callbackContext) {
        getRecognizer().cancel();
    }

    private void startSpeaking(String text, JSONObject options, CallbackContext callbackContext) {
        getSynthesizer().setParameter(SpeechConstant.VOICE_NAME, "xiaoyan");
        getSynthesizer().setParameter(SpeechConstant.SPEED, "50");
        getSynthesizer().setParameter(SpeechConstant.VOLUME, "80");
        
        //getSynthesizer().setParameter(SpeechConstant.SAMPLE_RATE, "8000");
        //getSynthesizer().setParameter(SpeechConstant.TTS_AUDIO_PATH,"./sdcard/tts.pcm");

        if (options != null) {
        	Iterator it = options.keys();
            while (it.hasNext()) {
                String key = (String) it.next();
                String value = options.optString(key);
                getSynthesizer().setParameter(key, value);
                //Log.w(LOGTAG, String.format("param: %s = %s", key, value));
            }
        }

        getSynthesizer().startSpeaking(text, this);
    }

    private void pauseSpeaking(CallbackContext callbackContext) {
        getSynthesizer().pauseSpeaking();
    }

    private void resumeSpeaking(CallbackContext callbackContext) {
        getSynthesizer().resumeSpeaking();
    }

    private void stopSpeaking(CallbackContext callbackContext) {
        getSynthesizer().stopSpeaking();
    }

    private void sendUpdate(JSONObject obj, boolean keepCallback, PluginResult.Status status) {
        if (callback != null) {
            PluginResult result = new PluginResult(status, obj);
            result.setKeepCallback(keepCallback);
            callback.sendPluginResult(result);
            if (!keepCallback) {
                callback = null;
            }
        }
    }

    private void sendUpdate(JSONObject obj, boolean keepCallback) {
        sendUpdate(obj, keepCallback, PluginResult.Status.OK);
    }

    private void fireEvent(String event) {
        JSONObject obj = new JSONObject();
        try {
            obj.put(STR_EVENT, event);
            sendUpdate(obj, true);
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    @Override
    public void onBufferProgress(int progress, int beginPos, int endPos,
            String info) {
        JSONObject obj = new JSONObject();
        try {
            obj.put(STR_EVENT, EVENT_BUFFER_PROGRESS);
            obj.put(STR_PROGRESS, progress);
            obj.put(STR_MESSAGE, info);
            sendUpdate(obj, true);
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    @Override
    public void onCompleted(SpeechError error) {
        JSONObject obj = new JSONObject();
        try {
            obj.put(STR_EVENT, EVENT_SPEAK_COMPLETED);
            if (error != null) {
                obj.put(STR_CODE, error.getErrorCode());
                obj.put(STR_MESSAGE, error.getErrorDescription());
            }
            sendUpdate(obj, true);
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    @Override
    public void onSpeakBegin() {
        fireEvent(EVENT_SPEAK_BEGIN);
    }

    @Override
    public void onSpeakPaused() {
        fireEvent(EVENT_SPEAK_PAUSED);
    }

    @Override
    public void onSpeakProgress(int progress, int beginPos, int endPos) {
        JSONObject obj = new JSONObject();
        try {
            obj.put(STR_EVENT, EVENT_SPEAK_PROGRESS);
            obj.put(STR_PROGRESS, progress);
            sendUpdate(obj, true);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onSpeakResumed() {
        fireEvent(EVENT_SPEAK_RESUMED);
    }

    @Override
    public void onBeginOfSpeech() {
        fireEvent(EVENT_SPEECH_BEGIN);

    }

    @Override
    public void onEndOfSpeech() {
        fireEvent(EVENT_SPEECH_END);

    }

    @Override
    public void onError(SpeechError error) {
        JSONObject obj = new JSONObject();
        try {
            obj.put(STR_EVENT, EVENT_SPEECH_ERROR);
            if (error != null) {
                obj.put(STR_CODE, error.getErrorCode());
                obj.put(STR_MESSAGE, error.getErrorDescription());
            }
            sendUpdate(obj, true);
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    @Override
    public void onEvent(int eventType, int arg1, int arg2, String msg) {
        Log.d(this.getClass().getName(), "onEvent " + eventType + " " + arg1 + " " + arg2 + " " + msg);
        // fireEvent(EVENT_SPEECH_ERROR);

    }

    @Override
    public void onResult(RecognizerResult result, boolean islast) {
        JSONObject obj = new JSONObject();
        try {
            obj.put(STR_EVENT, EVENT_SPEECH_RESULTS);
            //String text = parseIatResult(result.getResultString());
            String text = result.getResultString();
            obj.put(STR_RESULTS, text);
            sendUpdate(obj, true);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onVolumeChanged(int volume) {
        JSONObject obj = new JSONObject();
        try {
            obj.put(STR_EVENT, EVENT_VOLUME_CHANGED);
            obj.put(STR_VOLUME, volume * 100 / 30);
            sendUpdate(obj, true);
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    public static String parseIatResult(String json) {
        if (TextUtils.isEmpty(json))
            return "";

        StringBuffer ret = new StringBuffer();
        try {
            JSONTokener tokener = new JSONTokener(json);
            JSONObject joResult = new JSONObject(tokener);

            JSONArray words = joResult.getJSONArray("ws");
            for (int i = 0; i < words.length(); i++) {
                JSONArray items = words.getJSONObject(i).getJSONArray("cw");
                JSONObject obj = items.getJSONObject(0);
                ret.append(obj.getString("w"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ret.toString();
    }
}
