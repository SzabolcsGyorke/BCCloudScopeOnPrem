using System;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using System.Text.Encodings.Web;
using System.Text;
using System.Net.Http.Headers;
using System.Security.Claims;
namespace BCCloudScopeOnPrem.Handler
{
    public class BasicAuthenticationHandler: AuthenticationHandler<AuthenticationSchemeOptions>
    {
        public BasicAuthenticationHandler(IOptionsMonitor<AuthenticationSchemeOptions> option, ILoggerFactory logger, UrlEncoder encoder, ISystemClock clock):base(option,logger,encoder, clock)
        {

        }

        protected async override Task<AuthenticateResult> HandleAuthenticateAsync(){
            if (!Request.Headers.ContainsKey("Authorization"))
                return AuthenticateResult.Fail("");

            var _headervalue = AuthenticationHeaderValue.Parse(Request.Headers["Authorization"]);
            var bytes = Convert.FromBase64String(_headervalue.Parameter);
            string credentials = Encoding.UTF8.GetString(bytes);
            
            if (!string.IsNullOrEmpty(credentials)){
                string[] array = credentials.Split(":");
                string username = array[0];
                string password = array[1];
                //check if the BC App id and name is matching
                if ((username == "BC Cloud Scope OnPrem") & (password == "{A6CC51E5-D7D3-4723-9CAE-C8612A2316AD}")) {
                    var claim = new[]{new Claim(ClaimTypes.Name, username)};
                    var identity = new ClaimsIdentity(claim, Scheme.Name);
                    var principal = new ClaimsPrincipal(identity);
                    var ticket = new AuthenticationTicket(principal, Scheme.Name);
                    return AuthenticateResult.Success(ticket);
                }
            }
            //defult return
            return AuthenticateResult.Fail("");
        }
    }

}