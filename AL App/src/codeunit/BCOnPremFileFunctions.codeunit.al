codeunit 51000 "BC OnPrem File Functions"
{

    var
        BCOnPremFileHttpManagement: Codeunit "BC OnPrem File Http Management";
        RequestType: Option Get,patch,post,delete;
        SearchOption: Option TopDirectoryOnly,AllDirectories;
        QueryTxt: Label '{"action": "%1", "parameter1": "%2", "parameter2": "%3", "parameter3": "%4"}', Locked = true;
        ServerAddressTxt: Label 'http://localhost:49352/BCCouldScopeOnPrem', Locked = true;

    procedure GetServerDirectoryFilesList(var NameValueBuffer: Record "Name/Value Buffer"; DirectoryPath: Text)
    begin
        if NameValueBuffer.IsTemporary then
            NameValueBuffer.DeleteAll();

        QueryDirectoryContents(NameValueBuffer, DirectoryPath, '*.*', SearchOption::TopDirectoryOnly);
    end;

    procedure GetServerDirectoryFilesListInclSubDirs(var TempNameValueBuffer: Record "Name/Value Buffer" temporary; DirectoryPath: Text)
    begin
        TempNameValueBuffer.DeleteAll();

        QueryDirectoryContents(TempNameValueBuffer, DirectoryPath, '*.*', SearchOption::AllDirectories);
    end;

    local procedure QueryDirectoryContents(var NameValueBuffer: Record "Name/Value Buffer"; DirectoryPath: Text; SearchPattern: text; SearchOption: Option TopDirectoryOnly,AllDirectories)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        JsonArrayFiles: JsonArray;
        response: Text;
        FileNameandPath, FileName, FilePath, tt : Text;
        FileNameandPathExploded: List of [Text];
        i: Integer;
        ErrorMessage: Text;
        QueryFailErr: Label 'The query failed:\%1';
    begin
        response := BCOnPremFileHttpManagement.CallService(GetServerAddress(), RequestType::post, StrSubstNo(QueryTxt, 'ls', CheckFilePath(DirectoryPath), SearchPattern, Format(SearchOption)));
        JsonObject.ReadFrom(response);

        if JsonObject.Get('Success', JsonToken) then
            if not JsonToken.AsValue().AsBoolean() then begin
                JsonObject.Get('ErrorMessage', JsonToken);
                ErrorMessage := JsonToken.AsValue().AsText();
                Error(QueryFailErr, ErrorMessage);
            end;

        if JsonObject.Get('Files', JsonToken) then begin
            JsonArrayFiles := JsonToken.AsArray();
            foreach JsonToken in JsonArrayFiles do begin
                FileName := '';
                FilePath := '';
                FileNameandPath := JsonToken.AsValue().AsText();
                if StrPos(FileNameandPath, '\') > 0 then begin
                    FileNameandPathExploded := FileNameandPath.Split('\');
                    FileNameandPathExploded.Get(FileNameandPathExploded.Count, FileName);
                    for i := 1 to FileNameandPathExploded.Count - 1 do begin
                        FileNameandPathExploded.Get(i, tt);
                        FilePath += StrSubstNo('%1\', tt);
                    end;

                end;
                NameValueBuffer.AddNewEntry(FilePath, FileName);
                NameValueBuffer."Value Long" := FileNameandPath;
                NameValueBuffer.Modify();
            end;

        end;
    end;

    local procedure GetServerAddress(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if CompanyInformation."OnPrem File Service URL OPF" <> '' then
            exit(CompanyInformation."OnPrem File Service URL OPF")
        else
            exit(ServerAddressTxt);
    end;

    local procedure CheckFilePath(FilePath: Text): Text
    begin
        if (StrPos(FilePath, '\') > 0) and (StrPos(FilePath, '\\') = 0) then
            exit(FilePath.Replace('\', '\\'))
        else
            exit(FilePath);
    end;


    procedure BLOBImportFromServerFile(var TempBlob: Codeunit "Temp Blob"; FilePath: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        response: Text;
        Base64Value: Text;
        OutStream: OutStream;
        InStream: Instream;
    begin
        response := BCOnPremFileHttpManagement.CallService(GetServerAddress(), RequestType::post, StrSubstNo(QueryTxt, 'upload', CheckFilePath(FilePath), 'afteruploadaction', 'todir'));
        JsonObject.ReadFrom(response);

        if JsonObject.Get('Success', JsonToken) then
            if not JsonToken.AsValue().AsBoolean() then Error('The query failed');

        if JsonObject.Get('Base64Value', JsonToken) then
            Base64Value := JsonToken.AsValue().AsText();

        TempBlob.CreateOutStream(OutStream);
        Base64Convert.FromBase64(Base64Value, OutStream);
        TempBlob.CreateInStream(InStream);
        CopyStream(OutStream, InStream);
    end;

    procedure BLOBExportToServerFile(var TempBlob: Codeunit "Temp Blob"; FilePath: Text): Boolean
    var
        Base64Convert: Codeunit "Base64 Convert";
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        response: Text;
        Base64Value: Text;
        InStream: Instream;
    begin
        TempBlob.CreateInStream(InStream);
        Base64Value := Base64Convert.ToBase64(InStream);

        response := BCOnPremFileHttpManagement.CallService(GetServerAddress(), RequestType::post, StrSubstNo(QueryTxt, 'download', CheckFilePath(FilePath), Base64Value, 'nothing'));
        JsonObject.ReadFrom(response);
        if JsonObject.Get('Success', JsonToken) then
            if JsonToken.AsValue().AsBoolean() then
                exit(true)
            else
                exit(false);
    end;

    procedure CreateServerFolder(FolderPath: Text): Boolean
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        response: Text;
    begin
        response := BCOnPremFileHttpManagement.CallService(GetServerAddress(), RequestType::post, StrSubstNo(QueryTxt, 'mkdir', CheckFilePath(FolderPath), 'nothing', 'notihng'));
        JsonObject.ReadFrom(response);

        if JsonObject.Get('Success', JsonToken) then
            if JsonToken.AsValue().AsBoolean() then
                exit(true)
            else
                exit(false);
    end;

    procedure DeleteServerFile(FilePath: Text): Boolean
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        response: Text;
    begin
        response := BCOnPremFileHttpManagement.CallService(GetServerAddress(), RequestType::post, StrSubstNo(QueryTxt, 'erase', CheckFilePath(FilePath), 'nothing', 'notihng'));
        JsonObject.ReadFrom(response);

        if JsonObject.Get('Success', JsonToken) then
            if JsonToken.AsValue().AsBoolean() then
                exit(true)
            else
                exit(false);
        //we should have the error message in the response
    end;

    procedure GetServerFileProperties(FullFileName: Text; var ModifyDate: Date; var ModifyTime: Time; var Size: BigInteger): Boolean;
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        response: Text;
        LastWriteDateTime: DateTime;
    begin
        response := BCOnPremFileHttpManagement.CallService(GetServerAddress(), RequestType::post, StrSubstNo(QueryTxt, 'fileinfo', CheckFilePath(FullFileName), 'nothing', 'notihng'));
        JsonObject.ReadFrom(response);

        if JsonObject.Get('Success', JsonToken) then
            if JsonToken.AsValue().AsBoolean() then begin
                JsonObject.Get('FileLastWriteDateTime', JsonToken);
                LastWriteDateTime := JsonToken.AsValue().AsDateTime();
                ModifyDate := DT2Date(LastWriteDateTime);
                ModifyTime := DT2Time(LastWriteDateTime);
                JsonObject.Get('FileSize', JsonToken);
                Size := JsonToken.AsValue().AsBigInteger();
                exit(true);
            end;
    end;
}


