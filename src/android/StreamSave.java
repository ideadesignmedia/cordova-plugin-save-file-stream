package com.example.streamsave;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.webkit.MimeTypeMap;

import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONException;
import org.json.JSONObject;

import androidx.annotation.Nullable;

import org.apache.cordova.*;

import java.io.*;

public class StreamSave extends CordovaPlugin {

    private static final int REQUEST_CODE_SAVE_FILE = 1001;

    private CallbackContext callbackContext;
    private String sourcePath;
    private String mimeType;
    private String suggestedName;

    @Override
    public boolean execute(String action, CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        if ("exportFile".equals(action)) {
            this.callbackContext = callbackContext;

            JSONObject options = args.getJSONObject(0);
            this.sourcePath = options.getString("sourcePath");
            this.mimeType = options.getString("mimeType");
            this.suggestedName = options.getString("suggestedName");

            Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            intent.setType(mimeType);
            intent.putExtra(Intent.EXTRA_TITLE, suggestedName);

            cordova.setActivityResultCallback(this);
            cordova.getActivity().startActivityForResult(intent, REQUEST_CODE_SAVE_FILE);
            return true;
        }

        return false;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (requestCode == REQUEST_CODE_SAVE_FILE) {
            if (resultCode == Activity.RESULT_OK && intent != null) {
                Uri uri = intent.getData();
                if (uri != null) {
                    streamFileToUri(uri);
                } else {
                    callbackContext.error("No URI returned");
                }
            } else {
                callbackContext.error("User canceled");
            }
        }
    }

    private void streamFileToUri(Uri uri) {
        try {
            // Resolve source file
            String resolvedPath = FileUtils.getRealPath(sourcePath, cordova);
            if (resolvedPath == null) {
                callbackContext.error("Could not resolve file path");
                return;
            }

            InputStream inputStream = new FileInputStream(resolvedPath);
            ParcelFileDescriptor pfd = cordova.getActivity().getContentResolver().openFileDescriptor(uri, "w");
            OutputStream outputStream = new FileOutputStream(pfd.getFileDescriptor());

            byte[] buffer = new byte[8192];
            int length;

            while ((length = inputStream.read(buffer)) > 0) {
                outputStream.write(buffer, 0, length);
            }

            inputStream.close();
            outputStream.flush();
            outputStream.close();
            pfd.close();

            callbackContext.success("File saved");
        } catch (Exception e) {
            callbackContext.error("Failed to save file: " + e.getMessage());
        }
    }
}