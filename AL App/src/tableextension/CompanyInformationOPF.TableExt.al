tableextension 51000 "Company Information OPF" extends "Company Information"
{
    fields
    {
        field(51000; "OnPrem File Service URL OPF"; Text[250])
        {
            Caption = 'OnPrem File Service URL';
            DataClassification = CustomerContent;
        }

    }
}