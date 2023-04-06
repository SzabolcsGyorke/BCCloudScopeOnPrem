pageextension 51000 "Company Information OPF" extends "Company Information"
{
    layout
    {
        addlast(content)
        {
            group(grp_OPF)
            {
                Caption = 'On Prem File Service';

                field("OnPrem File Service URL OPF"; Rec."OnPrem File Service URL OPF")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OnPrem File Service URL field.';
                }
            }
        }
    }
}
