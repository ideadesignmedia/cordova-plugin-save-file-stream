package com.ideadesignmedia.streamsave;

import android.content.Context;
import android.os.Environment;

import org.apache.cordova.CordovaInterface;

import java.io.File;

public class FileUtils {
    public static String getRealPath(String cdvPath, CordovaInterface cordova) {
        if (cdvPath.startsWith("cdvfile://localhost/persistent/")) {
            String relative = cdvPath.replace("cdvfile://localhost/persistent/", "");
            return cordova.getActivity().getFilesDir().getParent() + "/files/" + relative;
        }
        if (cdvPath.startsWith("file://")) {
            return cdvPath.replace("file://", "");
        }
        return null;
    }
}