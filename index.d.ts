declare global {
    namespace CordovaPluginSaveFileStream {
        interface ExportFileOptions {
            sourcePath: string;
            suggestedName: string;
            mimeType: string;
        }

        interface SaveFileStream {
            exportFile(options: ExportFileOptions): Promise<void>;
        }
    }

    interface CordovaPlugins {
        streamSave: CordovaPluginSaveFileStream.SaveFileStream;
    }
}