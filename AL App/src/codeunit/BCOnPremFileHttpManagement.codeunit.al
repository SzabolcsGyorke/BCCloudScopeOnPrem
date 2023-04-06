codeunit 51001 "BC OnPrem File Http Management"
{
    procedure CallService(RequestUrl: Text; RequestType: Option Get,patch,post,delete; payload: Text): Text
    var
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
        myAppInfo: ModuleInfo;
    begin
        RequestHeaders := Client.DefaultRequestHeaders();
        NavApp.GetCurrentModuleInfo(myAppInfo);
        RequestHeaders.Add('Authorization', CreateBasicAuthHeader(myAppInfo.Name, Format(myAppInfo.Id)));

        case RequestType of
            RequestType::Get:
                Client.Get(RequestURL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(RequestURL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Post(RequestURL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(RequestURL, ResponseMessage);
        end;

        if ResponseMessage.HttpStatusCode <> 200 then
            Error('Error: %1', ResponseMessage.HttpStatusCode);

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    procedure CreateBasicAuthHeader(UserName: Text; Password: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(StrSubstNo('Basic %1', Base64Convert.ToBase64(StrSubstNo('%1:%2', UserName, Password))));
    end;
}
