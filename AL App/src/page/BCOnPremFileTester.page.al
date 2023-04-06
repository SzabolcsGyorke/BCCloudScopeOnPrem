page 51000 "BC OnPrem File Tester"
{
    ApplicationArea = All;
    Caption = 'BC OnPrem File Tester';
    PageType = List;
    SourceTable = "Name/Value Buffer";
    UsageCategory = Lists;
    SourceTableTemporary = true;
    SaveValues = true;
    layout
    {
        area(content)
        {
            group(Directories)
            {
                field(DirFrom; DirFrom)
                {
                    Caption = 'Server Directory From';
                }
                field(DirTo; DirTo)
                {
                    Caption = 'Server Directory To';
                }
            }
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the Excel column number.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the ID of the Azure Active Directory application that will be used to connect to Exchange.';
                }
                field("Value"; Rec."Value")
                {
                    ToolTip = 'Specifies the secret of the Azure Active Directory application that will be used to connect to Exchange.';
                }
                field("Value Long"; Rec."Value Long")
                {
                    ToolTip = 'Specifies the redirect URL of the Azure Active Directory application that will be used to connect to Exchange.';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            group(Directory)
            {
                actionref(GetDir_ref; GetDir) { }
                actionref(GetDirSub_ref; GetDirandSubDir) { }
                actionref(CreateDir_ref; CreateDir) { }
            }
            group(File)
            {
                actionref(DisplayFileContent_ref; DisplayFileContent) { }
                actionref(DeleteFile_ref; DeleteFile) { }
                actionref(SaveFileToServer_ref; SaveFileToServer) { }
                actionref(GetFileInfo_ref; GetFileInfo) { }
            }
        }
        area(Processing)
        {
            action(GetDir)
            {
                Caption = 'Get Directorylist';
                Image = FilterLines;
                trigger OnAction()
                begin
                    BCOnPremFileFunctions.GetServerDirectoryFilesList(Rec, DirFrom);
                end;
            }
            action(GetDirandSubDir)
            {
                Caption = 'Get Directory and Subdirectory list';
                Image = FilterLines;
                trigger OnAction()
                begin
                    BCOnPremFileFunctions.GetServerDirectoryFilesListInclSubDirs(Rec, DirFrom);
                end;
            }
            action(DisplayFileContent)
            {
                Caption = 'Open and display file content';
                ToolTip = 'Please do not open large files in a messagebox';
                Image = ShowWarning;
                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    InStr: Instream;
                    FileContentsText, tt : Text;
                begin
                    BCOnPremFileFunctions.BLOBImportFromServerFile(TempBlob, Rec."Value Long");
                    TempBlob.CreateInStream(InStr);
                    while not InStr.EOS do begin
                        InStr.ReadText(tt);
                        FileContentsText += tt;
                    end;
                    Message(FileContentsText);
                end;
            }
            action(DeleteFile)
            {
                Caption = 'Delete File';
                Image = Delete;
                trigger OnAction()
                var
                    ConfirmQst: Label 'Are you sure to delete?\%1', Comment = '%1 = file name';
                begin
                    if Confirm(ConfirmQst, false, Rec.Value) then
                        if BCOnPremFileFunctions.DeleteServerFile(Rec."Value Long") then rec.Delete();
                end;
            }
            action(CreateDir)
            {
                Caption = 'Create Directory';
                ToolTip = 'Create a directory with path using the Server Directory To';
                Image = Add;
                trigger OnAction()
                var
                    ConfirmQst: Label 'Do you want to create a new directory?';
                begin
                    if DirTo <> '' then
                        if Confirm(ConfirmQst, false) then
                            if BCOnPremFileFunctions.CreateServerFolder(DirTo) then Message('Folder created');
                end;
            }
            action(SaveFileToServer)
            {
                Caption = 'Save File To Server';
                ToolTip = 'Save the Comapny Info Image';
                Image = Save;
                trigger OnAction()
                var
                    CompanyInformation: Record "Company Information";
                    TempBlob: Codeunit "Temp Blob";
                    InStream: Instream;
                    OutStream: OutStream;
                    ConfirmQst: Label 'Do you want to save the company logo to the Server Directory To?';
                begin
                    CompanyInformation.get;
                    CompanyInformation.CalcFields(Picture);
                    if DirTo <> '' then
                        if CompanyInformation.Picture.HasValue then
                            if Confirm(ConfirmQst) then begin
                                CompanyInformation.Picture.CreateInStream(InStream);
                                TempBlob.CreateOutStream(OutStream);
                                CopyStream(OutStream, InStream);
                                BCOnPremFileFunctions.BLOBExportToServerFile(TempBlob, DirTo);
                            end;
                end;
            }
            action(GetFileInfo)
            {
                Caption = 'Get File Info';
                ToolTip = 'Get the file information formt the slected file';
                Image = Info;
                trigger OnAction()
                var
                    ModifyDate: Date;
                    ModifyTime: Time;
                    Size: BigInteger;
                    FileInfoMsg: Label '%1\Date: %2\Time: %3\Size: %4', Comment = '%1 - filename, %2 date, %3 - time, %4 - size';
                begin
                    if BCOnPremFileFunctions.GetServerFileProperties(Rec."Value Long", ModifyDate, ModifyTime, Size) then
                        Message(FileInfoMsg, Rec.Value, ModifyDate, ModifyTime, Size);
                end;
            }
        }
    }
    var
        BCOnPremFileFunctions: Codeunit "BC OnPrem File Functions";
        DirFrom: Text;
        DoskerTestDirTxt: Label 'c:\\run\\my';
        DirTo: Text;

    trigger OnOpenPage()
    begin
        DirFrom := DoskerTestDirTxt;
    end;
}
